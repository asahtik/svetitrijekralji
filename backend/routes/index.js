var express = require('express');
var router = express.Router();

const auth = require('../controllers/auth');
const hills = require('../controllers/hills');

router.post('/login', auth.login);
router.post('/register', auth.register);
router.get('/hills', hills.getAllHills);
router.get('/edges/:groupId', hills.getAllEdges);
router.get('/hills/:userId', hills.getFlaggedHills);
router.post('/test', auth.createOrJoinGroup);

module.exports = router;
