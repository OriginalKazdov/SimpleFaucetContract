//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract FaucetContract{
  mapping(address => bool) public hasClaimed;
  uint256 dripAmount= 0.02 ether;
  event Claimed(address indexed user, uint256 amount);

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

}
