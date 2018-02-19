pragma solidity ^0.4.18;

contract ShareAccount {
    
    struct AccountDetail {
        address owner;
        uint balance;
        bool isActive;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    
    modifier globalAccountControls {
        require(isAccuntExist(msg.sender));
        _;
    }
    
    mapping(address => AccountDetail) usersAccounts;
    
    address[] acAddress;
    address owner;
    address firstOwner;
    
    uint maxAccountCount;
    uint numberOfAccounts;
    
    function ShareAccount(uint _maxAccountCount) public {
         if(maxAccountCount != 0)
            maxAccountCount=_maxAccountCount;
         else
            maxAccountCount =128;
            
         owner = msg.sender;
         firstOwner = msg.sender;
         openAccount();
    }
    
    function openAccount() payable public {
        require(!isAccuntExist(msg.sender));
        usersAccounts[msg.sender] = AccountDetail(msg.sender,msg.value,true);
        acAddress.push(msg.sender);
        numberOfAccounts++;
    }
    
    function withDrawMoney(uint amount) globalAccountControls public {
        require(usersAccounts[msg.sender].balance >= amount);
        
        msg.sender.transfer(amount);
        usersAccounts[msg.sender].balance -= amount;
    }
    
    function dipositMoney(uint amount) payable public {
        require(isAccuntExist(msg.sender));
        require(msg.value == amount);
        usersAccounts[msg.sender].balance += msg.value ;
    }
    
    function isAccuntExist(address accountOwner) private constant returns (bool) {
        bool boolReturn = (usersAccounts[accountOwner].owner != address(0) && usersAccounts[accountOwner].isActive) ;
        return boolReturn;
    }
    
    function getOwnerAccounts(address addr) onlyOwner public constant returns (address,uint,bool) {
       // bytes memory tempAddress = bytes(addr);
        if(addr == address(0))
            addr=msg.sender;
            
          AccountDetail storage tempsUserInf =   usersAccounts[addr];
         return (tempsUserInf.owner,tempsUserInf.balance,tempsUserInf.isActive);
    }
    
    function getMyAccountInf() globalAccountControls public constant returns (address,uint) {
         AccountDetail storage tempsUserInf =   usersAccounts[msg.sender];
         return (tempsUserInf.owner,tempsUserInf.balance);
    }
    
    function changeOwner(address addr) onlyOwner public {
        require(isAccuntExist(addr));
        owner = addr;
    }
    
    function delAccount(address addr) onlyOwner public {
       require(usersAccounts[addr].balance>0);
       for(uint i = 0 ; i<numberOfAccounts-1 ; i++){
           if(acAddress[i]!=addr)
             usersAccounts[acAddress[i]].balance += usersAccounts[addr].balance/(numberOfAccounts-1);
           
       }
       
       usersAccounts[addr].balance=0;
       usersAccounts[addr].isActive=false;
    }
    
}