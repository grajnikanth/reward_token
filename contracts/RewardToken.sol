pragma solidity ^0.8.0;

import "ERC20.sol";              

    /**
     * @dev RewardToken contract creates a new ERC20 token with symbol RWT.
     * 
     * This contract was written to solve the interview challenge posted by Solace-fi @
     * https://github.com/solace-fi/solidity-challenge.
     * 
     * The RewardToken contract will inherit from open sourced openzeppelin ERC20 contract .
     * 
     */


contract RewardToken is ERC20 {

    address private contractOwner;          // Stores address of the account used to deploy contract.
    address private stakingAddress;         // Staking contract address stored to give approval to spend tokens and give approval to mint tokens.

    string public token_name = "Reward Token";
    string public token_symbol = "RWT";
    uint256 public INITIAL_SUPPLY = 1000000;
    uint public currentBlockNumber;

    /**
     * @dev sends the values for {name} and {symbol} to ERC 20 contract.
     *
     * Set contract owner address to the deploying address.
     * Mint initial supply of tokens.
     * Track current block number at contract creation.
     * 
     * All three of these values are immutable: they can only be set once during
     * construction.
     */

    constructor() ERC20(token_name, token_symbol) {
        contractOwner = msg.sender;

        _mint(msg.sender, INITIAL_SUPPLY);
        currentBlockNumber = block.number;          

    }
   
    /**
     * @dev store the staking contract address on Blockchain. The staking contract address will be authorized to mint schedule tokens.
     *
     */ 
     
    function authorizeStakingContract(address _stakingAddress) public {
        
        require(msg.sender == contractOwner,"Caller is not contract owner");    
        stakingAddress = _stakingAddress;
    }
    

    /**
     * @dev Contract owner or staking contract is used to mint 10 tokens per Block as rewards for stakers.
     *
     * Reset the blocknumber to mint more tokens from the current block
     * The minted tokens will be added to the staking contract current balance
     * 
     * 
     */
    
    function mintScheduleTokens() public {
        require(msg.sender == contractOwner || msg.sender == stakingAddress, "Caller is not authorized to create new tokens");
        uint256 tokensToCreate = (block.number - currentBlockNumber)*10;       
        _mint(stakingAddress, tokensToCreate);     
        currentBlockNumber = block.number;         
    }


    
}


    /**
     * @dev StakingRWT contract works with the RewardToken ERC20 contract to allow staking.
     * 
     * User wanting to stake tokens first have to approve the staking contract to spend user Tokens via the RewardToken contract.
     * Next uers can deposit RWT tokens into the staking contract.
     * Users can withdraw their tokens including the staking rewards minted proportional to their stake.
     * 
     */

contract StakingRWT {
    
    mapping (address => uint256) private stakeBalances;     // stores the deposit amount by each user.
    uint256 public totalStakedTokens;                       // stores the total RWT tokens staked by all users.
    uint256 public totalMintedRewardTokens;                 // stores the total new minted token rewards.
     address private contractOwner;                         // Stores the address of the account used to deploy contract.
    
    RewardToken rewardToken;        // Creates an instance of the deployed RewardToken contract to interact with it in this contract.
    
    
    /**
     * @dev stores the address of the contract creator and initialize an instance of the RewardToken contract.
     *
     * 
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    
    
    constructor(address rewardToken_address) {
        
        contractOwner = msg.sender;
        rewardToken = RewardToken(rewardToken_address);
    }
    
    /**
     * @dev users can use this function to send tokens to stake.
     *
     * This contract shall be approved by the user to spend their tokens to be able to deposit to the staking contract.
     * Once approved this function can be run to tranfer the tokens to the staking contrat by the user.
     * The amount staked by each user is stored in the stakeBalances mapping variable.
     * Total tokens staked by all users is tracked.
     * 
     */
    
    function deposit(uint256 amount) public {
        
        rewardToken.transferFrom(msg.sender, address(this), amount);
        stakeBalances[msg.sender] += amount;
        totalStakedTokens += amount;
        
    }
    
    
    /**
     * @dev user can use this function to fully withdraw their stake and the rewards they are entitled to.
     *
     * This funtion initiates a function call to RewardToken contract to mint new tokens 10 per each block.
     * Then the reward tokens are proportionally distributed to the user based on their stake.
     * The tokens are transferred back to the user. Their staked balance is set to 0 and the totalstaked tokens is adjusted 
     * to reflect withdrawal of staked tokens.
     * 
     * The attack vectors are minimized by  
     *      a) Not allowing contracts to withdraw funds,
     *      b) Verifying stake balances is > 0,
     *      c) deleting the balance of user prior to transferring tokens.
     * 
     */
    
    function withdraw() public {
        
        require(msg.sender == tx.origin, "Contracts not allowed to withdraw tokens");
        require(stakeBalances[msg.sender] > 0, "Caller does not have RWT tokens staked");
        rewardToken.mintScheduleTokens();
        uint256 contractBalance = rewardToken.balanceOf(address(this));
        uint256 callerTotalTokens = stakeBalances[msg.sender] + stakeBalances[msg.sender]*(contractBalance-totalStakedTokens)/totalStakedTokens;
        totalMintedRewardTokens = contractBalance-totalStakedTokens;
        totalStakedTokens -= stakeBalances[msg.sender];
        stakeBalances[msg.sender] = 0;
        rewardToken.transfer(msg.sender, callerTotalTokens);
    
    }
    

    /**
     * @dev getter function to obtain the total amount of tokens staked by a user.
     * 
     * 
     */
    
    function getStakeBalance(address _address) public view returns(uint256) {
        
        return stakeBalances[_address];
        
    }
    
    
    
}