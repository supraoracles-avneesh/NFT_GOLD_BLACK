pragma solidity^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract nfts is ERC1155{

    address public marketplaceAdmin;
    constructor () ERC1155("a.com") {
        _mint(msg.sender,1,100,"gold");
        _mint(msg.sender,2,100,"black");
        marketplaceAdmin = msg.sender;
    }

    function mint(address _owner, uint _tokenId, uint _value, string memory _data) public {
        require(msg.sender == marketplaceAdmin,"not admin");
        _mint(_owner,_tokenId,_value,bytes(_data));
    }


}

contract market is nfts,Ownable(msg.sender){

    uint constant public GOLD = 1;
    uint constant public BLACK = 2;


    struct Token{
        uint _id;
        string _name;
        uint _cost;
    }

    struct User {
        address _userAdd;
        uint[] _nftsBuyed;
        uint[] _tokensQuantity;
        uint[] _timeBuyed;
        uint _timeWhitelisted;
    }

    mapping(uint=>Token) public tokens;

    mapping(address=>User) public users;

    mapping(address=>uint) public withdrawnAmt;

    mapping(address=>bool) public registered;
    mapping(address=>bool) public whitelisted;
    uint public timeFrame1 = 100 seconds;
    uint public timeFrame2 = 200 seconds;
    uint public timeFrame3 = 300 seconds;
    uint public timeFrame4 = 400 seconds;
    uint public timeFrame5 = 500 seconds;

    event nftBuyed (address _user,uint _tokenId,uint timeStampBuyed);

    constructor() {
        tokens[1] = Token(1,"GOLD",100);
        tokens[2] = Token(2,"BLACK",50);
    }

    modifier NotRegistered() {
        require(!registered[msg.sender],"already registered");
        _;
    }
     modifier Registered(address _user) {
        require(registered[_user],"not registered");
        _;
    }

    modifier NotWhitelisted(address _user) {
        require(!whitelisted[_user],"already Whitelisted");
        _;
    }

    modifier Whitelisted(address _user) {
        require(whitelisted[_user],"not whitelisted");
        _;
    }


    function register() public NotRegistered{
        registered[msg.sender] = true;
    }

    function whitelist(address _user) public onlyOwner NotWhitelisted(_user) Registered(_user) {
        whitelisted[_user] = true;
        users[_user]._userAdd= _user;
    } 



    function tokenCost(uint _tokenID) internal view returns(uint) {
        return tokens[_tokenID]._cost ;
    }


    function buyNft(uint _tokenId,uint _quantity) public payable Whitelisted(msg.sender){
        uint nft_cost = tokens[_tokenId]._cost *  _quantity;
        require(users[msg.sender]._timeWhitelisted < block.timestamp + timeFrame1,"let the time frame start for you");
        require(msg.value == nft_cost,"msg.value is not exactly the same");
        _setApprovalForAll(owner(),msg.sender,true);
        string memory tokenName;
         if(_tokenId == 1) {
           tokenName = "GOLD";
        }else if(_tokenId == 2) {
            tokenName = "BLACK";
        }else{
            revert();
        }
        safeTransferFrom(owner(),msg.sender,_tokenId,_quantity,bytes(tokenName));
        User storage user = users[msg.sender];
        user._nftsBuyed.push(_tokenId);
        user._tokensQuantity.push(_quantity);
        user._timeBuyed.push(block.timestamp);
        _setApprovalForAll(owner(),msg.sender,false);
        emit nftBuyed(msg.sender, _tokenId, block.timestamp);
    }

    function redeem(address payable _user) public Whitelisted(msg.sender){
        require(_user == msg.sender,"enetered address is not the sender");
        uint amt = calculateReturns(_user);
        require(amt>0,"should have some balance");
        _user.transfer(amt);
        withdrawnAmt[_user] += amt;
    }

    function calculateReturns(address _user) public view returns(uint){
        User storage user = users[_user];
        uint totalGoldNft;
        uint totalBlackNft;
        uint Amt;
        uint GoldCost = tokenCost(1);
        uint BlackCost = tokenCost(2);
        for(uint i=0; i< user._nftsBuyed.length ;i++){
            if(user._nftsBuyed[i] == 1 && CalculateRedeemTimeFramePercentage(_user,i) > 0){
                totalGoldNft +=1;
                Amt += (GoldCost * CalculateRedeemTimeFramePercentage(_user,i))/100 ;
            }else if(user._nftsBuyed[i] == 2){
                totalBlackNft += 1;
                Amt += (BlackCost * CalculateRedeemTimeFramePercentage(_user,i))/100;
            }
        }
        uint totalAmt = Amt - withdrawnAmt[_user];
        return totalAmt;
    }

    function CalculateRedeemTimeFramePercentage(address _user,uint index) internal view returns(uint) {
        uint timeBuying = users[_user]._timeBuyed[index];
        uint timeDiff = block.timestamp - timeBuying;

        if(timeDiff < timeFrame1) {
            return 30;
        }else if (timeDiff >timeFrame1 && timeDiff < timeFrame2) {
            return 40;
        }else if(timeDiff > timeFrame2 && timeDiff <timeFrame3) {
            return 50;
        }else if(timeDiff>timeFrame3 && timeDiff<timeFrame4) {
            return 60;
        }else if(timeDiff>timeFrame4 && timeDiff<timeFrame5) {
            return 80;
        }else if(timeDiff>timeFrame5){
            return 100;
        }else {
            return 0;
        }
    }

   
}