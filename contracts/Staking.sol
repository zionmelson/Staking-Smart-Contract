// SPDX-License-Identifier: MIT

// What we want to do
// stake: Locking tokens in the smart contract
// withdrawl: Pulling tokens out of the smart contract
// claimReward: users claim reward from the smart contract
//      Reward mechanism?

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Staking__TransferFailed();
error Staking__WithdrawlFailed();
error Staking__NeedMoreThanZero();


contract Staking {
    IERC20 public s_stakingToken;
    IERC20 public s_rewardToken;

    uint256 public constant REWARD_RATE = 100;
    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdatedTime;

    // mapping how much each address has staked
    mapping(address => uint256) public s_balances;

    // mapping of how much each address has been paid
    mapping(address => uint256) public s_userRewardPerTokenPaid;

    // mapping of how much rewards each address has to claim
    mapping(address => uint256) public s_rewards;

    modifier updatedReward(address account) {
        // how much is reward per token?
        // get last timestamp
        // 12 - 1, user earned X tokens
        s_rewardPerTokenStored = rewardPerToken(); 
        s_lastUpdatedTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert Staking__NeedMoreThanZero();
        }
        _;
    }

    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);

    }

    function earned(address account) public view returns(uint256){
        uint256 currentBal = s_balances[account];
        // how much they have been paid
        uint256 amountPaid = s_userRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];

        uint256 _earned = ((currentBal * (currentRewardPerToken - amountPaid))/1e18) + pastRewards;
        return _earned;
    }

    // Based on most recent snapshot
    function rewardPerToken() public view returns(uint256) {
        if(s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        } 
        return s_rewardPerTokenStored + (((block.timestamp - s_lastUpdatedTime) * REWARD_RATE * 1e18) / s_totalSupply);
    }

    function stake(uint256 amount) external updatedReward(msg.sender) moreThanZero(amount) {
        s_balances[msg.sender] = s_balances[msg.sender] + amount;
        s_totalSupply = s_totalSupply + amount;
        bool transfered = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        if(!transfered){
            revert Staking__TransferFailed();
        }
    }

    function withdrawl(uint256 amount) external updatedReward(msg.sender) moreThanZero(amount) {
        s_balances[msg.sender] = s_balances[msg.sender] - amount;
        s_totalSupply = s_totalSupply - amount;
        bool withdrawled = s_stakingToken.transfer(msg.sender, amount);
        if(!withdrawled){
            revert Staking__WithdrawlFailed();
        }
    }

    function claimReward() external updatedReward(msg.sender) {
        uint256 reward = s_rewards[msg.sender];
        bool success = s_rewardToken.transfer(msg.sender, reward);
        if (!success) {
            revert Staking__TransferFailed();
        }
        //How much reward do they get?
        //
        //Contract will emit x tokens per second
        //And disperse to all token stakers
        //
        // 100 reward tokens / second
        // staked: 50 staked tokens, 20 staked tokens, 30 staked tokens
        // reward: 50 reward tokens, 20 reward tokens, 30 reward tokens
        //
        // staked: 100, 50, 20, 30 (200 total staked tokens)
        // reward:  50, 25, 10, 15 (100 total reward tokens)
        //
        // 5 seconds, 1 person has 100 tokens staked = (reward of 500 tokens)
        // 6 seconds, 2 people now have 100 tokens staked [someone else staked 100 tokens one second after]
        //       Person 1: 550  
        //       Person 2: 50  
        // ok between seconds 1 and 5, person 1 got 500 tokens
        // ok at second 6 on, person 1 gets 50 tokens now (since the pool will be split up with more people)
        //
        //
        // Time = 0
        // Person A: 80 staked
        // Person B: 20 staked
        //
        // Time = 1
        // PA: 80 staked, Earned: 80, Withdrawn: 0
        // PB: 20 staked, Earned: 20, Withdrawn: 0
        //
        // Time = 2
        // PA: 80 staked, Earned: 160, Withdrawn: 0
        // PB: 20 staked, Earned: 40, Withdrawn: 0
        //
        // Time = 3
        // PA: 80 staked, Earned: 240, Withdrawn: 0
        // PB: 20 staked, Earned: 60, Withdrawn: 0
        //
        // New person staked tokens!
        // Total of 200 staked tokens
        //
        // Time = 4
        // PA: 80 staked, Earned: 240 + (80/200 * 100 == 40) = 280, Withdrawn: 0
        // PB: 20 staked, Earned: 60 + (20/200 * 100 == 10)  = 70, Withdrawn: 0
        // PC: 100 staked, Earned: (100/200 * 100 == 50)     = 50, Withdrawn: 0
        // 
        // Formula for calculating earned tokens:
        // (amount staked / total amount) * reward/perSecond = rewardPerPerson
        // Examples:
        // (100/100) * 100 = 100 reward
        // 
        // (60/100) * 100 = 60 reward
        // (40/100) * 100 = 40 reward
        // 
        // (35/250) * 100 = 14 reward
        // (75/250) * 100 = 30 reward
        // (15/250) * 100 = 6 reward
        // (125/250) * 100 = 50 reward 
    }
}