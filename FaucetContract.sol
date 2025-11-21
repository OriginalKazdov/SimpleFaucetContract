//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract FaucetContract{
  mapping(address => bool) public hasClaimed;
  uint256 dripAmount= 0.02 ether;
  address payable public owner;
  event Claimed(address indexed user, uint256 amount);
  event Deposited(address indexed from, uint256 amount);
  event Withdrawn(address indexed to, uint256 amount);
  bool private locked;

  //modifier for owner role
  modifier onlyOwner(){
    require(msg.sender == owner, "Not owner");
    _;
  }

  //nonReentrant to prevent reentrancy manually
  modifier nonReentrant(){
    require(!locked, "Reentrant");
    locked = true;
    _;
    locked = false;
  }

  // Owner role without using openzeppelin standard
  constructor() {
    owner = payable(msg.sender);
  }

  //People can claim a small amount of tokens from this faucet
  function claim() external {
    // check if the address has received tokens already
    require(hasClaimed[msg.sender] == false, "Already claimed some drip");
    // store balance
    uint256 balance = address(this).balance;
    // compare balance with dripAmount to check if there's enough drip
    require(balance >= dripAmount, "There's not enough drip");
    hasClaimed[msg.sender] = true;
    // send drip to user if enough drip
    (bool sent, ) = msg.sender.call{value: dripAmount}("");
    require(sent, "Failed to send ether");
    emit Claimed(msg.sender, dripAmount);
  }

  function withdraw(uint256 amount) external onlyOwner nonReentrant(){
    require(address(this).balance >= amount, "Insufficient balance");
    (bool sent, ) = owner.call{value: amount}("");
    require(sent, "Withdraw failed");
    emit Withdrawn(owner, amount);

  }

  // this function let's the owner of the contract set a drip amount
  function setDrip(uint256 newAmount) external onlyOwner{
    dripAmount = newAmount;
  }

  receive() external payable {
    emit Deposited(msg.sender, msg.value);
  }

  fallback() external payable {
    emit Deposited(msg.sender, msg.value);
  }

}
