
// Progress as of 3/3/21

pragma solidity ^0.8.0;



import "ERC20.sol";             // This contract will inherit from the the openzeppelin ERC20 contract. 
import "SafeMath.sol";          // This contract will use SafeMath Library from openzeppeling.



contract RewardToken is ERC20 {

    using SafeMath for uint256;             // Allow SafeMath functions to be called for all uint256 types
    address private contractOwner;          // Account used to deploy contract
    address private stakingAddress;

    string public token_name = "Reward Token";
    string public token_symbol = "RWT";
    uint256 public INITIAL_SUPPLY = 1000;
    uint currentBlockNumber;

    constructor() ERC20(token_name, token_symbol) {
        contractOwner = msg.sender;

        _mint(msg.sender, INITIAL_SUPPLY);
        currentBlockNumber = block.number;

    }
    
    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool){
        
        super.transferFrom(_sender, _recipient, _amount);
        return true;
    }
    
    function authorizeStakingContract(address _stakingAddress) public {
        
        require(msg.sender == contractOwner,"Caller is not contract owner");
        stakingAddress = _stakingAddress;
    }
    
    function mintScheduleTokens() public {
        require(msg.sender == contractOwner || msg.sender == stakingAddress, "Caller is not authorized to create new tokens");
        uint256 tokensToCreate = (block.number - currentBlockNumber)*10;        // Create 10 new tokens per each block created from original block.
        _mint(stakingAddress, tokensToCreate);
        currentBlockNumber = block.number;          //reset block number for future token inflation calculation
    }


    
}


contract StakingRWT {
    
    using SafeMath for uint256;
    mapping (address => uint256) private stakeBalances;
    uint256 totalStakedTokens;
    
    RewardToken rewardToken;
    
    constructor(address rewardToken_address) {
        
        rewardToken = RewardToken(rewardToken_address);
    }
    
    
    function deposit(uint256 amount) public {
        
        rewardToken.transferFrom(msg.sender, address(this), amount);
        stakeBalances[msg.sender] += amount;
        totalStakedTokens += amount;
        
    }
    
    
    function withdraw() public {
        
        require(stakeBalances[msg.sender] > 0, "Caller does not have RWT tokens staked");
        calcTokenRewards();
        uint256 contractBalance = rewardToken.balanceOf(address(this));
        uint256 callerTotalTokens = stakeBalances[msg.sender] + stakeBalances[msg.sender]*(contractBalance-totalStakedTokens)/totalStakedTokens;
        stakeBalances[msg.sender] = 0;
        totalStakedTokens -= stakeBalances[msg.sender]*(contractBalance-totalStakedTokens)/totalStakedTokens;
        rewardToken.transfer(msg.sender, callerTotalTokens);
    

    }
    
    function calcTokenRewards() public {
        rewardToken.mintScheduleTokens();
        
        
    }
    
    
    
}