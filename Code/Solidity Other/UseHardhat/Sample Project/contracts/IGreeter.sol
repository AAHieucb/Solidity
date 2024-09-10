//SPDX-License-Identifier: Unlicense 
pragma solidity 0.8.4; 
interface IGreeter {
  function greet (  ) external view returns ( string memory );
  function setGreeting ( string memory _greeting ) external;
}
