// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

interface IForta {
    function setDetectionBot(address detectionBotAddress) external;
    function notify(address user, bytes calldata msgData) external;
    function raiseAlert(address user) external;
}

contract DetectionBot is IDetectionBot {
  address private cryptoVault;
  IForta private fortaContract;

  constructor(address forta, address cryptoVault_) {
    fortaContract = IForta(forta);
    cryptoVault = cryptoVault_;
  }
  
  function handleTransaction(address user, bytes calldata msgData) public override {
    // Only the Forta contract can call this method
    require(msg.sender == address(fortaContract), "Unauthorized");

    // Decode the msgData to get the original sender
    (,,address origSender) = abi.decode(msgData[4:], (address, uint256, address));

    // If origSender is crypto vault, raise alert
    if(origSender == cryptoVault) {
      fortaContract.raiseAlert(user);
    }

  }
}
