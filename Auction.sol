//https://rinkeby.etherscan.io/address/0x365373dDEE59766FF98Ca987Af1f775621d0d35E
pragma solidity ^0.4.21;

contract AuctionFuncs {
    uint difranceTime ;
    uint startTime;
    uint stopTime;
    
    struct Auctioneer {
        uint balance;
        address addr;
        bool isActive;
    }
    
    address accountOfBiggestOffer;
    
    address[] tempAuctioneer;
    
    mapping(address => Auctioneer) Auctioneers ;
    
    event WinnerMessage(bool isAuctionFinish,string Message,address addr);
    
    function AuctionFuncs() public {
        
        difranceTime = 15 minutes;
        startTime = now;
        stopTime = startTime + difranceTime;
        
    }
    
    function isTheTimeFull() internal constant returns(bool){
    
        if(stopTime>=now)
            return true;
        else
            return false;
            
    }
    
    function createAccount(uint _amount) internal {
        
        Auctioneer memory auctioneerItem = Auctioneer(_amount,msg.sender,true);
        
        Auctioneers[msg.sender]=auctioneerItem;
        
        tempAuctioneer.push(msg.sender);
        
        if(accountOfBiggestOffer==address(0))
             accountOfBiggestOffer= msg.sender;
             
    }
    
    function calcBiggestOffer() internal {
        if(Auctioneers[msg.sender].balance>Auctioneers[accountOfBiggestOffer].balance){
            accountOfBiggestOffer=msg.sender;
        }
    }
    
    function isAccuntExist(address accountOwner) internal constant returns (bool) {
        bool boolReturn = (Auctioneers[accountOwner].addr != address(0) && Auctioneers[accountOwner].isActive) ;
        return boolReturn;
    }
    
    function returnPayAuctioneer() internal {
        //uint storage i ; 
        
        address tempAddr ;
        
        for(uint i=0;i<tempAuctioneer.length;i++){
            tempAddr = tempAuctioneer[i] ;
            if(tempAddr!=accountOfBiggestOffer)
                if(tempAddr.send(Auctioneers[tempAuctioneer[i]].balance))
                        delete(Auctioneers[tempAddr]);
        }
    }
    
    /* // Bu kontrolü burda yapıp yapmamak arasında kararsız kaldım sonuçta teklif veren en sonki tefliften daha yüksek vermeli total de . 
    function getBiggestOffer() public returns(uint) {
        returns Auctioneers[accountOfBiggestOffer].balance;
    }
    */
}

contract Auction is AuctionFuncs {
    
    address owner;
    
    modifier onlyOwner {
        require(msg.sender==owner);
        _;
    }
    
    function Auction() public {
        owner=msg.sender;
    }
    
    function transferOwner(address _addr) public onlyOwner {
        owner = _addr;
    }
    
    function setIncrease() public payable {
        
        if(isTheTimeFull()){
            
            if(isAccuntExist(msg.sender)){
                Auctioneers[msg.sender].balance += msg.value;
            }
            else{
                createAccount(msg.value);
            }
            
            calcBiggestOffer();
            
            //emit WinnerMessage(true,"Fiyat arttırışı gerçekleştirildi. ",accountOfBiggestOffer); // Bu kısım DApps yapacağımız zaman geri bildirim için 
        }
        else
            getWinner();
            
    }
    
    function getWinner()  public returns(string){
        
        if(!isTheTimeFull()){
            
            //emit WinnerMessage(true,"Müzaede sonlanmıştır ilginiz için teşekkür ederiz. ",accountOfBiggestOffer); // Bu kısım DApps yapacağımız zaman geri bildirim için 
            
            msg.sender.send(msg.value);
            
            returnPayAuctioneer();
            
            return "Müzaede sonlanmıştır ilginiz için teşekkür ederiz. ";
        }
        else{
            //emit WinnerMessage(false,"Müzaede hala devam ediyor. ",address(0)); // Bu kısım DApps yapacağımız zaman geri bildirim için 
            
            return "Müzaede hala devam ediyor.  ";
        }
        
    }
    
    function getAccountBalance(address _addr) public constant onlyOwner returns(uint){
        
        return Auctioneers[_addr].balance;
        
    }
    
    
}