// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * NovaFi - Simple Escrow / Payment Contract (DeFi Base Example)
 * - User deposit funds for order
 * - Merchant can withdraw after confirmation
 * - Admin can refund if needed
 */

contract NovaFi {

    address public owner;

    struct Order {
        address payer;
        address merchant;
        uint256 amount;
        bool isPaid;
        bool isReleased;
        bool isRefunded;
    }

    mapping(uint256 => Order) public orders;
    uint256 public orderCount;

    event OrderCreated(uint256 orderId, address payer, address merchant, uint256 amount);
    event PaymentReleased(uint256 orderId);
    event Refunded(uint256 orderId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Create order and lock funds in contract
    function createOrder(address _merchant) external payable returns (uint256) {
        require(msg.value > 0, "No payment");

        orderCount++;

        orders[orderCount] = Order({
            payer: msg.sender,
            merchant: _merchant,
            amount: msg.value,
            isPaid: true,
            isReleased: false,
            isRefunded: false
        });

        emit OrderCreated(orderCount, msg.sender, _merchant, msg.value);

        return orderCount;
    }

    // Release payment to merchant
    function releasePayment(uint256 _orderId) external {
        Order storage order = orders[_orderId];

        require(order.isPaid, "Not paid");
        require(!order.isReleased, "Already released");
        require(msg.sender == order.payer || msg.sender == owner, "Not authorized");

        order.isReleased = true;

        payable(order.merchant).transfer(order.amount);

        emit PaymentReleased(_orderId);
    }

    // Refund payer (admin only)
    function refund(uint256 _orderId) external onlyOwner {
        Order storage order = orders[_orderId];

        require(order.isPaid, "Not paid");
        require(!order.isReleased, "Already released");
        require(!order.isRefunded, "Already refunded");

        order.isRefunded = true;

        payable(order.payer).transfer(order.amount);

        emit Refunded(_orderId);
    }

    // Check order detail
    function getOrder(uint256 _orderId) external view returns (Order memory) {
        return orders[_orderId];
    }
}
