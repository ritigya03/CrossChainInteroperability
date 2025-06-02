// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IntentsManager
/// @notice This contract stores and manages user-submitted trade intents
contract IntentsManager {
    uint256 public intentCounter;

    enum IntentStatus {
        Submitted,
        Fulfilled,
        Cancelled
    }

    struct Intent {
        address user;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 chainId; // Cross-chain target (simulated)
        IntentStatus status;
        uint256 timestamp;
    }

    mapping(uint256 => Intent) public intents;

    /// @notice Emitted when a user submits a new intent
    event IntentSubmitted(
        uint256 indexed intentId,
        address indexed user,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 chainId,
        uint256 timestamp
    );

    /// @notice Emitted when an intent's status is updated
    event IntentStatusUpdated(uint256 indexed intentId, IntentStatus newStatus);

    /// @notice Submit a new trade intent
    /// @param tokenIn The address of the token the user wants to give
    /// @param tokenOut The address of the token the user wants to receive
    /// @param amountIn Amount of input tokens
    /// @param minAmountOut Minimum acceptable output tokens
    /// @param chainId The target chain (simulated)
    function submitIntent(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 chainId
    ) external returns (uint256 intentId) {
        require(tokenIn != address(0), "Invalid tokenIn");
        require(tokenOut != address(0), "Invalid tokenOut");
        require(amountIn > 0, "Amount must be > 0");

        intentId = intentCounter++;
        intents[intentId] = Intent({
            user: msg.sender,
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amountIn: amountIn,
            minAmountOut: minAmountOut,
            chainId: chainId,
            status: IntentStatus.Submitted,
            timestamp: block.timestamp
        });

        emit IntentSubmitted(
            intentId,
            msg.sender,
            tokenIn,
            tokenOut,
            amountIn,
            minAmountOut,
            chainId,
            block.timestamp
        );
    }

    /// @notice Mark an intent as fulfilled (only callable by solver/router in full DEX setup)
    /// @param intentId ID of the intent to mark fulfilled
    function markFulfilled(uint256 intentId) external {
        require(intents[intentId].status == IntentStatus.Submitted, "Not active");
        intents[intentId].status = IntentStatus.Fulfilled;
        emit IntentStatusUpdated(intentId, IntentStatus.Fulfilled);
    }

    /// @notice Allows a user to cancel their submitted intent before it is fulfilled
    /// @param intentId ID of the intent to cancel
    function cancelIntent(uint256 intentId) external {
        require(intents[intentId].user == msg.sender, "Not your intent");
        require(intents[intentId].status == IntentStatus.Submitted, "Cannot cancel");

        intents[intentId].status = IntentStatus.Cancelled;
        emit IntentStatusUpdated(intentId, IntentStatus.Cancelled);
    }

    /// @notice Get full intent details by ID
    /// @param intentId The ID of the intent to query
    /// @return The full Intent struct
    function getIntent(uint256 intentId) external view returns (Intent memory) {
        return intents[intentId];
    }
} 