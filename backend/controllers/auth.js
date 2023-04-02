const axios = require('axios');

async function login(req, res) {
  axios.post('http://localhost:3000/api/collections/users/auth-with-password', req.body)
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

async function createGroup(name) {
  const newGroup = await axios.post('http://localhost:3000/api/collections/groups/records', 
    {
      'name' : name
    }
  );
  return newGroup.data;
}

async function createAscents(hills, groupid) {
  try {
    for (let i = 0; i < hills.length; i++) {
      const hill = hills[i];
      await axios.post('http://localhost:3000/api/collections/ascents/records', 
        {
          'hill': hill.id,
          'group': groupid
        }
      );
    }
  } catch (e) {
    if (e.response) {
      res.status(e.response.status).json(e.response.statusText);
    } else {
      console.error(e);
      res.status(500).json({"error": "Internal error"});
    }
  }
}

async function register(req, res) {
  try {
    const groupsResponse = await axios.get(`http://localhost:3000/api/collections/groups/records?filter=(name='${req.body.groupname}')`);
    if (groupsResponse.data.items.length == 0) {
      const newGroup = await createGroup(req.body.groupname);
      req.body.group = newGroup.id;
      const data = await axios.post('http://localhost:3000/api/collections/users/records', req.body);
      const hillsResponse =  await axios.get('http://localhost:3000/api/collections/hills/records?page=1&perPage=1000');
      createSubgraph(newGroup.id, hillsResponse, req);
      createAscents(hillsResponse.data.items, newGroup.id);
      res.status(200).json(data.data);
    } else {
      req.body.group = groupsResponse.data.items[0].id;
      const data = await axios.post('http://localhost:3000/api/collections/users/records', req.body);
      res.status(200).json(data.data);
    }
  } catch (e) {
    if (e.response) {
      res.status(e.response.status).json(e.response.statusText);
    } else {
      console.error(e);
      res.status(500).json({"error": "Internal error"});
    }
  }
}

async function createSubgraph(groupid, response) {
  var subgraph = createRandomSubgraph(response.data.items);
  try {
    for (let i = 0; i < subgraph.length; i++) {
      await axios.post('http://localhost:3000/api/collections/edges/records', {
        'group' : groupid,
        'hill1': subgraph[i][0],
        'hill2': subgraph[i][1]
      });
    }
  } catch (e) {
    if (e.response) {
      res.status(e.response.status).json(e.response.statusText);
    } else {
      console.error(e);
      res.status(500).json({"error": "Internal error"});
    }
  }
}

function thisConnectionExists(subgraph, mnt1, mnt2) {
  for(let i = 0; i < subgraph.length; i++) {
    if((subgraph[i][0] == mnt1.id && subgraph[i][1] == mnt2.id) ||
        (subgraph[i][1] == mnt1.id && subgraph[i][0] == mnt2.id)) {
          return true;
    }
  }
  return false;
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
      
      if(getAlreadyEstablishedConnections(mountains[i], subgraph) < maxAllowedConnectionsOfOneMountain && mountains[i].id != currMountain.id) {
          var dst = getDistance(currMountain, mountains[i]);
          
          var indexToInsert = getIndexToInsert(nearestNNeighbours, dst, currMountain)
          
          if(indexToInsert < n && !thisConnectionExists(subgraph, currMountain, mountains[i])) {
            nearestNNeighbours.splice(indexToInsert, 0, mountains[i]);
              if(nearestNNeighbours.length > n) {
                  nearestNNeighbours.slice(0, n);
              }
          }

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

module.exports = {
    login,
    register
}