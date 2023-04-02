const axios = require('axios');

async function getNumUsers(req, res) {
    try {
        const data = await axios.get("http://localhost:3000/api/collections/users/records?page=1&perPage=1");
        res.status(200).json({"count": data.data.totalItems});
    } catch (e) {
        if (e.response) {
            res.status(e.response.status).json(e.response.statusText);
        } else {
            console.error(e);
            res.status(500).json({"error": "Internal error"});
        }
    }
}

async function getNumClimbs(req, res) {
    try {
        const data = await axios.get("http://localhost:3000/api/collections/ascenthistory/records?page=1&perPage=1");
        res.status(200).json({"count": data.data.totalItems});
    } catch (e) {
        if (e.response) {
            res.status(e.response.status).json(e.response.statusText);
        } else {
            console.error(e);
            res.status(500).json({"error": "Internal error"});
        }
    }
}

async function getMostVisited(req, res) {
    try {
        const data = await axios.get("http://localhost:3000/api/collections/ascenthistory/records?page=1&perPage=9999&expand=ascent");
        const hills = data.data.items.filter((a) => a.user != "").map((a) => a.expand.ascent.hill);
        const hillCounts = {};
        hills.forEach((x) => { hillCounts[x] = (hillCounts[x] || 0) + 1;});
        const counts = Object.entries(hillCounts);
        counts.sort((a, b) => b[1] - a[1]);
        var ret = [];
        for (let i = 0; i < Math.min(counts.length, 10); i++) {
            const hill = await axios.get(`http://localhost:3000/api/collections/hills/records/${counts[i][0]}`);
            ret.push({"hill": hill.data, "count": counts[i][1]});
        }
        res.status(200).json({"items": ret});
    } catch (e) {
        if (e.response) {
            res.status(e.response.status).json(e.response.statusText);
        } else {
            console.error(e);
            res.status(500).json({"error": "Internal error"});
        }
    }
}

module.exports = {
    getNumUsers,
    getNumClimbs,
    getMostVisited
}