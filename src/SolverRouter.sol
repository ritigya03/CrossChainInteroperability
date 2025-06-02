// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IntentsManager } from "./IntentsManager.sol";
import { CoWMatcher } from "./CoWMatcher.sol";
import { CFMMAdapter } from "./CFMMAdapter.sol";

contract SolverRouter {
    IntentsManager public intentsManager;
    CoWMatcher public cowMatcher;
    CFMMAdapter public cfmmAdapter;

    event IntentFulfilled(
        uint256 indexed intentId,
        address solver,
        bool usedCoW,
        uint256 amountOut
    );

    constructor(
        address _intentsManager,
        address _cowMatcher,
        address _cfmmAdapter
    ) {
        intentsManager = IntentsManager(_intentsManager);
        cowMatcher = CoWMatcher(_cowMatcher);
        cfmmAdapter = CFMMAdapter(_cfmmAdapter);
    }

    /// @notice Called by solver to fulfill a single user intent using either CoW or CFMM
    function fulfillIntent(uint256 intentId, uint256 matchedIntentId) external {
        // 1. Get the intent details
        IntentsManager.Intent memory intent = intentsManager.getIntent(intentId);

        // 2. Check if the intent is active
        require(intent.status == IntentsManager.IntentStatus.Submitted, "Intent not active");

        uint256 amountOut;
        bool usedCoW = false;

        // 3. Try CoW match
        if (ICoWMatcher(address(cowMatcher)).canMatch(intentId, matchedIntentId)) {
            amountOut = ICoWMatcher(address(cowMatcher)).executeCoWTrade(intentId, matchedIntentId);
            usedCoW = true;
        } else {
            // 4. Fallback to CFMM
            amountOut = cfmmAdapter.swap(
                intent.tokenIn,
                intent.tokenOut,
                intent.amountIn,
                intent.minAmountOut
            );
        }

        // 5. Mark the intent as fulfilled
        intentsManager.markFulfilled(intentId);

        emit IntentFulfilled(intentId, msg.sender, usedCoW, amountOut);
    }
}

interface ICoWMatcher {
    function canMatch(uint256 intentA, uint256 intentB) external view returns (bool);
    function executeCoWTrade(uint256 intentA, uint256 intentB) external returns (uint256 amountOut);
}
