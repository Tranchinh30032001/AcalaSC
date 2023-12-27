// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Crowdsponsor {
    address public owner;
    enum TypePackage {Titanium, Gold, Silver}
    
    struct Event {
        string name;
        address[] participants;
        TypePackage category;
        mapping (address => uint256) balanceAddress;
    }

    mapping(address => string[]) public mapClientEvent;
    mapping(string => Event) public DetailEvent;

    event Deposit(address indexed participant, TypePackage category, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function deposit(TypePackage _package, string memory name) external payable {
        uint256 amount;
        if (_package == TypePackage.Titanium) {
            amount = 500;
        } else if (_package == TypePackage.Gold) {
            amount = 300;
        } else if (_package == TypePackage.Silver) {
            amount = 200;
        } else {
            revert("Invalid package type");
        }
        require(msg.value == amount, "Incorrect deposit amount");

         // Create a new event and assign values
        Event storage newEvent = DetailEvent[name];
        newEvent.name = name;
        newEvent.participants.push(msg.sender);
        newEvent.category = _package;
        newEvent.balanceAddress[msg.sender] += amount;
        mapClientEvent[msg.sender].push(name);

        emit Deposit(msg.sender, _package, amount);
    }

    function withdraw() external {
        require(msg.sender == owner, "Only the owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}
