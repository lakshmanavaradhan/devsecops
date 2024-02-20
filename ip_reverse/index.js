const express = require('express'); //webapp framework
const axios = require('axios');   //http client

const app = express();
const port = 3000;

app.get('/', async (req, res) => {
  try {
    const response = await axios.get('https://api64.ipify.org?format=json');
    const publicIP = response.data.ip;
    const reverseIP = publicIP.split('.').reverse().join('.')	  
    res.send(`<h1>Your Public IP is</h1><p>${publicIP}</p></n><h1>Your Public IP in reverse:</h1><p>${reverseIP}</p>`);
  } catch (error) {
    console.error('Error fetching public IP:', error);
    res.send('<h1>Error fetching IP</h1>');
  }
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
