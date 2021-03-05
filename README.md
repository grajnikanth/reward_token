# Solace-fi Solidity ERC20 Contract Challenge

In this project, I created contracts to meet the Solace-fi solidity contract challenge located at https://github.com/solace-fi/solidity-challenge

All the solidity contract files are located in the "contracts" folder.

## Smart Contracts

I used the following three contracts from openzeppelin open source code located at https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol.
 1. ERC20.sol
 2. IERC20.sol
 3. Context.sol

The contracts I created are as follows:

### RewardToken.sol
This contract implements the logic for creating a new ERC20 token called RWT.

### StakingRWT.sol
This contract implements the logic for staking tokens and withdrawal of the tokens staked along with the rewards generated. 

## Steps to run these smart contracts
1. Deploy RewardToken.sol to a local blockhain.
2. Deploy StakingRWT.sol to a local blockchain. Provide the contract address of RewardToken.sol as input to this contract while deploying.
3. The contratowner now has 100,000 RWT ERC20 tokens. Transfer some of the tokens to other accounts to test the staking contract.
4. Call the rewardToken.sol "approve" function and provide the address of the staking contract and amount of tokens approved to be used by the staking contract. Do this prior to depositing tokens into staking contract for each user.
5. Call the rewardToken.sol "authorizeStakingContract" function and provide the address of the staking contract. This will allow the staking contract to mint new tokens per the schedule.
6. Call the StakingRWT.sol deposit functions to deposit tokens.
7. Call the StakingRWT.sol withdraw function to withdraw tokens along with rewards.
