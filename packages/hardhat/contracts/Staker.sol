pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 24 hours;
  bool openWithdraw= false;





  event Stake(address staker , uint256 amount);

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
 
  }

    modifier notCompleted() {
    require(exampleExternalContract.completed() == false, "Contract is already executed");
    _;

  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  function stake() public payable { 
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value


  function execute() public notCompleted {
  require(block.timestamp >= deadline,"The contract hasn't reached the deadline yet!");
    if(address(this).balance >= threshold){
      exampleExternalContract.complete{
        value: address(this).balance
      }();
      deadline = block.timestamp + 30 seconds;
    }
    else{
      openWithdraw= true;
    }
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw(address payable withdrawer) public notCompleted {
    require(msg.sender == withdrawer);
    require(openWithdraw, "You can't withdraw yet");
    require(balances[withdrawer] > 0, " You don't have any funds");
    uint256 balance = balances[withdrawer];
    balances[withdrawer] = 0;
    withdrawer.transfer(balance);

  }



  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) return 0;
    return deadline - block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  } 



}
