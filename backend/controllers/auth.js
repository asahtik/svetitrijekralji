const axios = require('axios');

async function login(req, res) {
  axios.post('http://88.200.37.122:3000/api/collections/users/auth-with-password', req.body)
  .then(function (response) {
    res.status(200).json(response.data);
  })
  .catch(function (error) {
    if (error.response) {
        res.status(error.response.status).json(error.response.data)
    } else {
        res.status(500).json(error);
    }
  });
}

async function createOrJoinGroup(req, res) {
  axios.get(`http://88.200.37.122:3000/api/collections/groups/records?filter=(name='${req.body.groupname}')`, {
    headers: {
      'Authorization': req.body.authentication
    }
  })
  .then(function (response) {
    console.log(response);
    if (response.data.items.length == 0) {
      axios.post('http://88.200.37.122:3000/api/collections/groups/records',{
        'name' : req.body.groupname
        },{
        headers : {
          'Authorization': req.body.authentication
        }})
      .then(function (groupidresponse) {
        axios.get(`http://88.200.37.122:3000/api/collections/hills/records`, {
          headers: {
            'Authorization': req.body.authentication
          }
        }).then(function (response) {

          createSubgraph(groupidresponse.data.id, response, req);
        }).catch(function (error) {
            if (error.response) {
              //console.log(error)
                res.status(error.response.status).json(error.response.data)
            } else {
              //console.log(error);
                res.status(500).json(error);
            }
          });
      })
      .catch(function (error) {
        if (error.response) {
            res.status(error.response.status).json(error.response.data)
        } else {
            res.status(500).json(error);
        }
      });
    } else {
      res.status(200).json(response.data);
    }
  })
  .catch(function (error) {
    if (error.response) {
        res.status(error.response.status).json(error.response.data)
    } else {
        res.status(500).json(error);
    }
  });
}

function createSubgraph(groupid, response, req) {
  var subgraph = createRandomSubgraph(response.data.items);
  console.log(subgraph);
  for (let i = 0; i < subgraph.length; i++) {
    axios.post('http://88.200.37.122:3000/api/collections/edges/records', {
      'group' : groupid,
      'hill1': subgraph[i][0],
      'hill2': subgraph[i][1]
    }, {
      headers : {
        'Authorization': req.body.authentication
      }
    });
  }
}

function createRandomSubgraph(mountains) {
    
  const subgraph = [];

  for(let i = 0; i < mountains.length; i++) {
      currMountain = mountains[i];

      var alreadyEstablishedConnections = getAlreadyEstablishedConnections(currMountain, subgraph)

      var outOfThisManyConnections = 5;
      var pickThisManyConnections = 
      (3 - alreadyEstablishedConnections) <= 0 ? 0 : (3 - alreadyEstablishedConnections);

      const nearestNeighbours = pickNearestNeighbours(outOfThisManyConnections, 
        pickThisManyConnections, currMountain, mountains, subgraph);


      for(let j = 0; j < nearestNeighbours.length; j++) {
          subgraph.push([currMountain.id, nearestNeighbours[j].id]);
      }
  }
  //console.log("nekineki" + subgraph);
  return subgraph;
}

function getDistance(m1, m2) {
  return Math.sqrt((m1.longitude-m2.longitude) * (m1.longitude-m2.longitude) + 
      (m1.latitude-m2.latitude) * (m1.latitude-m2.latitude))
}           

function getIndexToInsert(nearestNeighbours, dst, currMountain) {
  for(let i = 0; i < nearestNeighbours.length; i++) {
      if(getDistance(currMountain, nearestNeighbours[i]) > dst) {
          return i;
      }
  }
  return nearestNeighbours.length;
}

function getNNearestNeighbours(n, currMountain, mountains, 
  subgraph, maxAllowedConnectionsOfOneMountain) {

  const nearestNNeighbours = [];

  for(let i = 0; i < mountains.length; i++) {
      
      if(getAlreadyEstablishedConnections(mountains[i], subgraph) < maxAllowedConnectionsOfOneMountain) {
          var dst = getDistance(currMountain, mountains[i]);
          
          var indexToInsert = getIndexToInsert(nearestNNeighbours, dst, currMountain)
          
          if(indexToInsert < n) {
              nearestNNeighbours.splice(indexToInsert, 0, mountains[i]);
              if(nearestNNeighbours.length > n) {
                  nearestNNeighbours.slice(0, n);
              }
          }
          //console.log(indexToInsert);
      }

  }

  return nearestNNeighbours;
}

function pickNearestNeighbours(outOfThisManyConnections, pickThisManyConnections, currMountain, mountains, subgraph) {

  if(pickThisManyConnections == 0) {
      return [];
  }
  
  const nNearestNeighbours = getNNearestNeighbours(outOfThisManyConnections, 
    currMountain, mountains, subgraph, pickThisManyConnections);

  //console.log(nNearestNeighbours);

  pickThisManyConnections = 
    pickThisManyConnections > nNearestNeighbours.length ? nNearestNeighbours.length : pickThisManyConnections;

  return nNearestNeighbours.slice(0, pickThisManyConnections);
}




function getAlreadyEstablishedConnections(currMountain, subgraph) {

  var numberOfConnections = 0;

  for(let i = 0; i < subgraph.length; i++) {
      if(subgraph[i][0].id == currMountain.id || subgraph[i][1].id == currMountain.id) {
          numberOfConnections++;
      }
  }

  return numberOfConnections;
}

async function register(req, res) {
  axios.post('http://88.200.37.122:3000/api/collections/users/records', req.body)
  .then(function (response) {
    res.status(200).json(response);
  })
  .catch(function (error) {
    if (error.response) {
        res.status(error.response.status).json(error.response.data)
    } else {
        res.status(500).json(error);
    }
  });
}

module.exports = {
    login,
    register,
    createOrJoinGroup
}