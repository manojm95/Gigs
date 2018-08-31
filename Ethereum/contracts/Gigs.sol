pragma solidity  ^0.4.17;

contract FactoryGig {
    
    struct GigRepoStruct {
        address[] GigsAddresses;
        bool exists;
    }
    mapping(string =>GigRepoStruct) GigsRepoMap;
    
    address[] public recentgigs;
    address[] public ts;
    
    //test1
    uint public tnoOfStars;
    uint public tstars;
    bool public tvalue;
    
    struct Bidder {
        uint noOfStars;
        uint stars;
        bool isValue;
    }
    mapping(address=>Bidder) Bidders;

    
    uint public manoj=0;

    //now this contract would receive the minimum amount that should be spent to be a contributors
    //and this would call campaign contract with that value
    function createGig(string category, string desc, uint bidStart, uint split, address FG) public {
        //the below line deploys the new campain contract and returns an address
        //we have to also pass the msg.sender from here to get the correct one
        address newGig = new Gig(category, desc, bidStart, split, msg.sender, FG);
        
        recentgigs.push(newGig);
        
        if(GigsRepoMap[category].exists){
            GigRepoStruct storage bdrStct = GigsRepoMap[category];
            bdrStct.GigsAddresses.push(newGig);
        }else{
            if(ts.length == 1){
                delete ts[0];
                ts[0] = newGig;
            }
            else {
                ts.push(newGig);
            }
            //ts.push(newGig);
            GigRepoStruct memory tempBidStct = GigRepoStruct({
                GigsAddresses:ts, 
                exists: true
            });
            
            GigsRepoMap[category] = tempBidStct;
        }
        
        
    }
    
      function test1(address index) public payable {
        Bidder storage bdr = Bidders[index];
        tnoOfStars = bdr.noOfStars;
        tstars = bdr.stars;
        
    }
    

    //to get all deployed contracts
    function getCatContracts(string category) public view returns (address[]) {
        
        if(GigsRepoMap[category].exists){
            GigRepoStruct storage bdrStct = GigsRepoMap[category];
            return bdrStct.GigsAddresses;
        }
        
    }
    
    function getRecentGigs() public view returns (address[15]) {
        address[15] memory temp;
        uint  arrayLength;
        uint  counter = 0;
        bool gt15 = false;
        uint diff = 0;
        arrayLength = recentgigs.length;
        if(arrayLength>15) { 
            gt15 = true; 
            diff = arrayLength - 15;
        }
        for (uint i=arrayLength-1; i<arrayLength; i--) {
            //temp.push(recentgigs[i]);
            temp[counter] = recentgigs[i];
            counter++;
            if(gt15){
                if(i==diff) break;
            }else
            {
                if(i==0) break;
            }
        }
        
        return temp;
    }
    
    function setManoj(uint v) public{
        manoj = v;
    }
    
    function rateBidders(address bidder, uint currStar) public{
        
        if(Bidders[bidder].isValue){
            Bidder storage bdr = Bidders[bidder];
            uint noOfStarsrecent = bdr.noOfStars+1;
            bdr.stars = ((bdr.stars * bdr.noOfStars) + currStar)/noOfStarsrecent;
            bdr.noOfStars = noOfStarsrecent;
        }else{
            Bidder memory tempBid = Bidder({
                noOfStars:1,
                stars: currStar,
                isValue: true
            });
            
            Bidders[bidder] = tempBid;
        }
    }
}

contract GFInterface {
    uint public manoj;
    function setManoj(uint v) public {}
    function rateBidders(address bidder, uint currStar) public{}
    //function set(uint _x) returns(bool success) {} 
}

contract Gig {
    
    //constructor params
    string public category;
    string public description;
    uint public contractBid;
    uint public paymentSplit;
    address public manager;
    address public parentContract;
    
    address public winningBidder;
    string public contractStatus='bidcrtd';
    
    //st - started
    //pr - payment requested
    //ar - approve request
    string public stage = 'st';
    //split stage
    uint public splitStage=0;
    bool public gigClosed = false;
    
    uint public pendingPercent=0;
    uint public totalPercent=0;
    address public tadd;
    uint public tval;

    struct Bid {
        address bidAdd;
        uint value;
    }
    Bid[] bidders;

    struct Request {
        string desc;
        uint value;
        bool complete;
        bool reject;
    }
    
    
    Request[] public requests;

    
    constructor(string cat, string desc, uint bidStart, uint split, address creator, address con ) public
    {
	  manager = creator;    
      category = cat;
      description = desc;
      contractBid = bidStart;
      paymentSplit = split;
      parentContract = con;
    }
    
    function placeQuote(uint value) public payable {
            require(msg.sender != manager);
            Bid memory newBid = Bid ({
                bidAdd: msg.sender,
                value: value
                
            });
            bidders.push(newBid);
    }
    
    
    function test1(uint index) public payable {
        Bid storage bdr = bidders[index];
        tadd = bdr.bidAdd;
        tval = bdr.value;
        
    }
    
    function paymentRequest(uint percentage) public payable {
        require(percentage < (100 - totalPercent));
        require(msg.sender==winningBidder);
        stage = 'pr';
        splitStage++;
        pendingPercent = percentage;
    }
    
    function approvePayment() public payable {
        require(msg.sender==manager);
        stage = 'ar';
        totalPercent = pendingPercent + totalPercent;
        if(splitStage==paymentSplit) {
            contractStatus = 'gigcomp';
            gigClosed = true;
        }
        //derive the value to be sent. Pending
        winningBidder.transfer(contractBid*(pendingPercent/100));
    }
    
    function confirmBid(address bidder, uint index) public payable {
        require (msg.sender == manager);
        winningBidder = bidder;
        //setting the accepted bid as contract value accepted for the gig
        Bid storage bdr = bidders[index];
        contractBid = bdr.value;
        contractStatus = 'bidcomf';
    }
    
    
    function test(uint temp) public {
        GFInterface e = GFInterface(parentContract);
        e.setManoj(temp);
    }
    
    
    function rate(address bidder, uint currStar) public {
        require(msg.sender==manager);
        GFInterface e = GFInterface(parentContract);
        e.rateBidders(bidder, currStar);
    }
    
      function createSpecialRequest(string desc, uint value )
            public restricted
    {
            Request memory newRequest = Request({
               desc: desc,
               value: value,
               complete: false,
               reject: false
            });

            requests.push(newRequest);
    }
    
    function finalizeRequest(uint index) public {
        Request storage rq = requests[index];
        require(msg.sender == manager);
        require(!rq.complete);
        winningBidder.transfer(rq.value);
        rq.complete = true;
    }
    
     function rejectRequest(uint index) public {
        Request storage rq = requests[index];
        require(msg.sender == manager);
        require(!rq.complete);
        rq.reject = true;
        rq.complete = true;
    }

    function getbidders() public view returns (address) {
        Bid storage rq = bidders[0];
        return rq.bidAdd;
    }

    modifier restricted() {
        require(msg.sender == winningBidder);
        _;
    }
}

