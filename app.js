const express = require('express');
const path = require('path');
const pool = require('./db');
const session = require('express-session');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 8080;

app.use(express.urlencoded({ extended: true }));

app.use(session({
  secret: process.env.SECRET_KEY,
  resave: false,
  saveUninitialized: false,
}));

function checkAuth(req, res, next) {
  if (req.session.user) {
    return next();
  } else {
    return res.redirect('/');
  }
}

app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/html/login.html'));
});

app.post('/login', (req, res) => {
  const { email, password } = req.body;
  if (email === process.env.ADMIN_EMAIL && password === process.env.ADMIN_PASSWORD) {
    req.session.user = email;
    res.redirect('/update');
  } else {
    res.redirect('/?error=true');
  }
});

app.get('/logout', (req, res) => {
  req.session.destroy(err => {
    if (err) {
      return res.status(500).send('Error logging out');
    }
    res.redirect('/');
  });
});

app.get('/update', checkAuth, (req, res) => {
  res.sendFile(path.join(__dirname, 'public/html/update_balance.html'));
});

app.post('/update', checkAuth, (req, res) => {
  const { balance_regis, balance_topup, balance_min_topup, balance_payment } = req.body;
  const updateBalanceQuery = 'UPDATE balance_config SET balance = $1 WHERE balance_type = $2';

  const tasks = [
    pool.query(updateBalanceQuery, [balance_regis, 'regis']),
    pool.query(updateBalanceQuery, [balance_topup, 'topup']),
    pool.query(updateBalanceQuery, [balance_min_topup, 'min_topup']),
    pool.query(updateBalanceQuery, [balance_payment, 'payment']),
  ];

  Promise.all(tasks)
    .then(() => res.redirect('/update?success=true'))
    .catch(err => res.status(500).json({ success: false, message: 'Error updating balances' }));
});


app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
