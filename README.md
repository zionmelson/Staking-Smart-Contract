# Staking-Smart-Contract
**Chainlink Spring 2022 Hackathon Code-Along** 

This is the basics for a Token Staking Application built with Smart Contracts
*****************************************************************************

The two smart contracts are:

can be found in contracts/RewardToken.sol
can be found in contracts/Staking.sol

RewardToken.sol
Staking.sol

RewardToken.sol: Creating a smart contract to create the reward token
Staking.sol: Creating the functionality of the staking platform. 
             There are three main functions (stake, withdrawl, & claimReward)
             stake: adds the amount passed in parameter to the balance of the
             address who passes the function as well as adding this amount to
             total supply 
             withdrawl: subtracts the amount passed in parameter to the balance of the
             address who passes the function as well as subtracting this amount to
             total supply 
             claimReward: claims the reward the user has accumalated
             ////////////////////////////////////////////////////////////////
             There are two modifiers (updateReward & moreThanZero)
             updateReward: takes in one address parameter of account and updates 
             user reward info and current reward balance so that the following 
             functions (stake, withdrawl, & claimReward) can be ran properly
             moreThanZero: makes sure that user stakes and withdrawls amount 
             higher than 0
             ///////////////////////////////////////////////////////////////
             
             
There are three main folders to pay attention to as well:

deploy
test
utils

in deploy/00-deploy-reward-token.js:
Deploys the reward token from the "RewardToken" contract

in deploy/01-deploy-staking.js:
Deploys staking contract while also taking in the reward token address
as arguments from the previous "00-deploy-reward-token.js" deployal

#######################################################################

in utils/move-blocks.js:
I call an async function moveBlocks to simulate the next block being 
added to the network for testing purposes

in utils/move-time.js:
I call an async function moveTime to simulate the moving of time in 
seconds on the blockchain network

######################################################################

in test/staking.test.js:

I grab both contracts using the "getContract()" function and call some 
basic functions from the "Staking" smart contract. The test is showing 
a user staking 10000 tokens and then it's showing how much reward token
that user will make in a day and a year. (currently it is set to "SEC_IN_DAY")

You will also notice that we call the "moveTime" and "moveBlock" functions 
to simulate the validation of the previous block and the time passed. 
This gives us a different "endEarned" than the "startEarned" because the 
block hasn't validated the transcation at the beginning.

#######################################################################

The major objective of all these folders is to

1. Deploy the contract after it as been compiled
2. Give block functionality to the test to simulate
   a real block chain.
3. Test the functionality of the smart contract



____________________________________________________________________________________
Footnote: This is my first project where I fully understood the functionality of the 
code. Chainlink Labs provides amazing code alongs and as my understanding for the 
space grows I will continue to add more complex projects to my repositories!
