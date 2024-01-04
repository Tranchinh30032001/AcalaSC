// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Crowdsponsor {
    address public owner;
    enum TypePackage {Titanium, Gold, Silver}
    
    struct Event {
        string eventId;
        string name;
        address[] participants;
        TypePackage category;
        uint256 priceTitanium;
        uint256 priceGold;
        uint256 priceSilver;
    }

    mapping(address => string[]) public mapClientEvent;
    mapping(string => Event) public detailEvent; // eventId -> Event

    event Deposit(address indexed participant, TypePackage category, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function createEvent (string memory _name, string memory _eventId, uint256 _priceTitanium, uint256 _priceGold, uint256 _priceSilver) public {
            Event memory newEvent = Event({
                eventId: _eventId,
                name: _name,
                participants: new address[](0),
                priceTitanium: _priceTitanium,
                priceGold: _priceGold,
                priceSilver: _priceSilver,
                category: TypePackage.Gold
            });
            mapClientEvent[msg.sender].push(_eventId);
            detailEvent[_eventId] = newEvent;
    }


    function deposit(TypePackage _package, string memory _eventId, uint256 _price) external payable {
        Event storage eventObject = detailEvent[_eventId];
        uint256 amount;
        if (_package == TypePackage.Titanium) {
            require(_price == eventObject.priceTitanium, "You deposit not enough price of Titanium Package");
        } else if (_package == TypePackage.Gold) {
            require(_price == eventObject.priceGold, "You deposit not enough price of Gold Package");
        } else if (_package == TypePackage.Silver) {
            require(_price == eventObject.priceTitanium, "You deposit not enough price of Silver Package");
        } else {
            revert("Invalid package type");
        }

        detailEvent[_eventId].participants.push(msg.sender);

        emit Deposit(msg.sender, _package, amount);
    }

    function withdraw() external {
        require(msg.sender == owner, "Only the owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}