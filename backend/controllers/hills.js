const axios = require('axios');

async function getAllHills(req, res) {
  axios.get('http://localhost:3000/api/collections/hills/records?sort=id&perPage=999', {
    headers: req.headers
  })
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

async function getGroupAscents(req, res) {
  const groupId = req.params["groupId"];
  axios.get(`http://localhost:3000/api/collections/ascents/records?filter=(group.id='${groupId}')&sort=-created&perPage=999`, {
    headers: req.headers
  })
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

async function getAllEdges(req, res) {
  const groupId = req.params["groupId"];
  axios.get(`http://localhost:3000/api/collections/edges/records?filter=(group.id='${groupId}')`, {
    headers: req.headers
  })
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

async function getFlaggedHills(req, res) {
  const userId = req.params["userId"];
  axios.get(`http://localhost:3000/api/collections/ascents/records?filter=(user.id='${userId}')&expand=hill&perPage=999`, {
    headers: req.headers
  })
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

async function flagAscent(req, res) {
  const ascentId = req.params["ascentId"];
  const userId = req.body["userId"];
  try {
    const data = await axios.patch(`http://localhost:3000/api/collections/ascents/records/${ascentId}`, {
      "user": userId
    }, {
      headers: {
        "Authorization": req.headers["authorization"],
        "Content-Type": "application/json"
      }
    });
    await axios.post("http://localhost:3000/api/collections/ascenthistory/records", {
      "ascent": ascentId,
      "user": userId,
      "time": new Date().toISOString()
    }, {
      headers: {
        "Authorization": req.headers["authorization"],
        "Content-Type": "application/json"
      }
    })
    const ascents = await axios.get(`http://localhost:3000/api/collections/ascents/records?filter=(group.id='${data.data.group}')&page=1&perPage=999&expand=hill`);
    const edges = await axios.get(`http://localhost:3000/api/collections/edges/records?filter=(group.id='${data.data.group}')&page=1&perPage=999`);
    await updatePoints(ascents.data, edges.data, req.headers["authorization"]);
    res.status(200).json(data.data);
  } catch (e) {
    if (e.response) {
      res.status(e.response.status).json(e.response.statusText);
    } else {
      console.log(e);
      res.status(500).json({"error": "Internal error"});
    }
  }
}

async function updatePoints(ascents, edges, auth) {
  var hillsPerUser = {};
  for (var i = 0; i < ascents.items.length; i++) {
    const a = ascents.items[i];
    if (a.user) {
      if (!hillsPerUser[a.user]) {
        hillsPerUser[a.user] = [];
      }
      hillsPerUser[a.user].push(a.expand.hill);
    }
  }
  var edgesPerUser = {};
  for (var user in hillsPerUser) {
    edgesPerUser[user] = [];
    const hillIdsPerUser = hillsPerUser[user].map((h) => h.id);
    for (var e of edges.items) {
      if (hillIdsPerUser.includes(e.hill1) && hillIdsPerUser.includes(e.hill2)) {
        edgesPerUser[user].push(e);
      }
    }
  }
  var pointsPerUser = {};
  for (var user in hillsPerUser) {
    pointsPerUser[user] = calculatePoints(hillsPerUser[user], edgesPerUser[user]);
    await axios.patch(`http://localhost:3000/api/collections/users/records/${user}`, {
      "points": pointsPerUser[user]
    }, {
      headers: {
        "Authorization": auth,
        "Content-Type": "application/json"
      }
    });
  }
}

function findIx(mnt, mnts) {
  for(let i = 0; i < mnts.length; i++) {
    if(mnts[i].id.localeCompare(mnt) == 0) {
      return i;
    }
  }
  return -1;
}

//calculate points of each user using a page ranking algorithm
function calculatePoints(climbedMountainsOfThisUser, climbedConnections) {
  const weight = 0.1;
  const numIters = 5;
  pointsOfClimbedMountains = climbedMountainsOfThisUser.map((m) => m.height / 100);

  for (let j = 0; j < numIters; j++) {
    for(let i = 0; i < climbedConnections.length; i++) {
      var ix1 = findIx(climbedConnections[i].hill1, climbedMountainsOfThisUser);
      var ix2 = findIx(climbedConnections[i].hill2, climbedMountainsOfThisUser);
      oldPoints1 = pointsOfClimbedMountains[ix1];
      oldPoints2 = pointsOfClimbedMountains[ix2];
      pointsOfClimbedMountains[ix1] += weight * oldPoints2;
      pointsOfClimbedMountains[ix2] += weight * oldPoints1;
    }
  }

  return Math.round(pointsOfClimbedMountains.reduce((partialSum, a) => partialSum + a), 2);
}

module.exports = {
    getAllHills,
    getGroupAscents,
    getAllEdges,
    getFlaggedHills,
    flagAscent
}