var express = require('express');
var router = express.Router();

const auth = require('../controllers/auth');
const hills = require('../controllers/hills');
const users = require('../controllers/users');
const stats = require('../controllers/stats');

router.post('/login', auth.login);
router.post('/register', auth.register);
router.get('/hills', hills.getAllHills);
router.get('/edges/:groupId', hills.getAllEdges);
router.get('/hills/:userId', hills.getFlaggedHills);
router.get('/ascents/:groupId', hills.getGroupAscents);
router.put('/flag/:ascentId', hills.flagAscent);
router.get('/users/:groupId', users.getUsers);

router.get('/stats/numusers', stats.getNumUsers);
router.get('/stats/numclimbs', stats.getNumClimbs);
router.get('/stats/mostvisited', stats.getMostVisited);

module.exports = router;
