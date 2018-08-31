const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const provider = ganache.provider();
const web3 = new Web3(provider);

const compiledFactory = require('../Ethereum/build/FactoryGig.json');
const compiledGig = require('../Ethereum/build/Gig.json');

let accounts;
let factory;
let gigAddress;
let gig;
let category;

const { interface, bytecode  } = compiledFactory;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();
  console.log('11111',accounts[0]);
 
  factory = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: bytecode })
    .send({ from: accounts[0], gas:'3000000' });
console.log('22222');
  await factory.methods.createGig('ceiling','ceiling','1000',4,factory.options.address).send({
    from: accounts[0],
    gas: '3000000'
  });
console.log('33333');

  [gigAddress] = await factory.methods.getCatContracts('ceiling').call();
  gig = await new web3.eth.Contract(
    JSON.parse(compiledGig.interface),
    gigAddress
  );
  
  category = await gig.methods.category().call();
factory.setProvider(provider);
});

describe('Gigs', () => {
  it('deploys a factory and a gig', () => {
    assert.ok(factory.options.address);
    assert.ok(gig.options.address);
  });
  it('check the category', ()=> {
    assert.equal(category,'ceiling');
  });

  it('check placing quote', async ()=> {
     await gig.methods.placeQuote('100').send({
		from: accounts[1],
		gas: '1000000'
     });
     const add = await gig.methods.getbidders().call();
     console.log('444444'+accounts[1]+'5555555',add);
     assert.equal(add,accounts[1]);
  });

   it('confirm bid', async ()=> {
	console.log('aaaaaaaaaaaaaaa');
	 await gig.methods.placeQuote('100').send({
                from: accounts[1],
                gas: '1000000'
     	 });

        const add = await gig.methods.getbidders().call();
	console.log('bbbbbbbbb',add);     
	await gig.methods.confirmBid(add,'0').send({
                from: accounts[0],
                gas: '1000000'
     	});
     	console.log('99999999999999');
     	const add1 = await gig.methods.contractStatus().call();
     	//console.log('555555',contractStatus);
     	assert.equal(add1,'bidcomf');
  });
  
   it('check manager', async ()=> {
        console.log('aaaaaaaaaaaaaaa');
	try {
         await gig.methods.placeQuote('100').send({
                from: accounts[1],
                gas: '1000000'
         });
	 //console.log('bbbbbbbbb',add);
         await gig.methods.confirmBid(accounts[1],'0').send({
                from: accounts[0],
                gas: '1000000'
        });
	console.log('falseeee');
	 assert(false);
 	}catch(err)
	{
	console.log(err);
	  assert(err);
	}

   });	
});
