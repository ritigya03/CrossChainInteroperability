// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IntentsManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CoWMatcher {
IntentsManager public intents;
constructor(address _intents) {
    intents = IntentsManager(_intents);
}

event CoWExecuted(uint256 intentA, uint256 intentB, uint256 clearingPrice);

function matchAndExecute(uint256 idA, uint256 idB) external {
    IntentsManager.Intent memory intentA = intents.getIntent(idA);
    IntentsManager.Intent memory intentB = intents.getIntent(idB);

    require(intentA.status == IntentsManager.IntentStatus.Submitted, "Intent A not active");
    require(intentB.status == IntentsManager.IntentStatus.Submitted, "Intent B not active");

    // Validate opposite trades
    require(intentA.tokenIn == intentB.tokenOut, "Token mismatch A->B");
    require(intentA.tokenOut == intentB.tokenIn, "Token mismatch B->A");

    // Price validation
    // For simplicity, we check if both minAmountOut conditions are satisfied at midpoint price
    uint256 clearingPrice = computeClearingPrice(intentA, intentB);

    uint256 amountOutA = (intentA.amountIn * clearingPrice) / 1e18;
    uint256 amountOutB = (intentB.amountIn * 1e18) / clearingPrice;

    require(amountOutA >= intentA.minAmountOut, "A slippage");
    require(amountOutB >= intentB.minAmountOut, "B slippage");

    // Execute token transfers atomically
    IERC20(intentA.tokenIn).transferFrom(intentA.user, intentB.user, intentA.amountIn);
    IERC20(intentB.tokenIn).transferFrom(intentB.user, intentA.user, intentB.amountIn);

    // Update status via external call
    intents.markFulfilled(idA);
    intents.markFulfilled(idB);

    emit CoWExecuted(idA, idB, clearingPrice);
}

function computeClearingPrice(IntentsManager.Intent memory A, IntentsManager.Intent memory B) public pure returns (uint256) {
    // Midpoint price (A.amountIn / A.minAmountOut + B.minAmountOut / B.amountIn) / 2
    uint256 priceA = (A.amountIn * 1e18) / A.minAmountOut;
    uint256 priceB = (B.minAmountOut * 1e18) / B.amountIn;
    return (priceA + priceB) / 2;
}
}

