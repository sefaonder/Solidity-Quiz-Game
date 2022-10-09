# Solidity-Quiz-Game

## Basic Explanation
Simple Quiz game written in [Solidity](https://docs.soliditylang.org).Users create their own quiz and players play them.The first to guess the correct answer wins and all the pledged is transferred to the winner. If no one guesses correctly, the creator can claim pledged amount.

## Contract Functions
| FunctionName | Parameters | Description |
| ----------- | ----------- | ----------- |
| launch | *answerHash,**endDate, price, ***uri | start the quiz |
| guess | id,answer | quess the quiz |
| claimMoney | id | claim all pledged money if there was a no winner |
| viewAllQuizes | - | see all quizes on the blockchain |

1. *answerHash:Data should be stored hash because players can able to see storage in the blockchain.
2. **endDate:takes value in milliseconds.
3. ***uri:Storing data on blockchain is very costly so there is a URL to reference them for details.


## How to Run
Quick and easy way to Run this contract use [Remix IDE](http://remix.ethereum.org).
For more [information](https://www.geeksforgeeks.org/steps-to-execute-solidity-smart-contract-using-remix-ide/).


## Dependencies
This contract uses 2 openzeppelin dependencies.
[IERC20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol)
[Counters](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol)

## Task List
- [x] Write the contract
- [ ] Write a front-end for this contract
- [ ] Deploy the contract ETH testnet (Rinkeby,Ropsten etc.)

## Contribute
This is a open source [Practium](https://cohorts.patika.dev/cohortDetails/akbank-web3-practicum) final project.But feel free to open pull requests.