// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
function approve(address spender, uint256 amount) external returns (bool);
function balanceOf(address user) external view returns (uint256);
function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IUniswapV2Router {
function swapExactTokensForTokens(
uint amountIn,
uint amountOutMin,
address[] calldata path,
address to,
uint deadline
) external returns (uint[] memory amounts);
}

contract CFMMAdapter {
address public router;

pgsql
Copy
Edit
constructor(address _router) {
    router = _router;
}

/// @notice Executes fallback swap via Uniswap V2 router
function executeFallbackSwap(
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    uint256 minAmountOut,
    address user
) external returns (uint256 amountOut) {
    // Pull tokens from user
    require(IERC20(tokenIn).transferFrom(user, address(this), amountIn), "Transfer failed");

    // Approve router
    require(IERC20(tokenIn).approve(router, amountIn), "Approval failed");

    // Set path (tokenIn -> tokenOut)
    address ;
    path[0] = tokenIn;
    path[1] = tokenOut;

    // Execute swap
    uint[] memory amounts = IUniswapV2Router(router).swapExactTokensForTokens(
        amountIn,
        minAmountOut,
        path,
        user, // Send output tokens directly to user
        block.timestamp + 15 minutes
    );

    amountOut = amounts[amounts.length - 1];
}
}

—

🧪 Test: test/CFMMAdapter.t.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CFMMAdapter.sol";

contract CFMMAdapterTest is Test {
CFMMAdapter public adapter;
address public mockRouter = address(0xDEAD); // Replace with mock or real router

csharp
Copy
Edit
function setUp() public {
    adapter = new CFMMAdapter(mockRouter);
}

function testDummy() public {
    // You can extend this with a mocked IUniswapV2Router
    assertEq(address(adapter.router), mockRouter);
}
}