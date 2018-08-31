//web3 initialized with provider
import web3 from './web3';
//importing this to get AIB/interface for deploymnet
const campaignFactory = require('./build/FactoryCampaign.json');


//building the pointer to deployed instance with AIB/interface
const instance = new web3.eth.Contract(
   JSON.parse(campaignFactory.interface),
   '0x2806e1b26e504843E3de8DB91435A5E9307c7390'
);

export default instance;


