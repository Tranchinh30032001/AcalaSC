// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.2.0/proxy/Clones.sol";
import "./ICollection.sol";

contract NFTCreatorFactory {
    struct CollectionInfo {
        uint recordId;
        address creator;
        uint nonce;
    }

    struct CreatorInfo {
        address creator;
        uint claimedAmount;
    }

    mapping(address => CollectionInfo) public collectionInfo;
    mapping(uint256 => address) public recordIdCollection;
    mapping(address => address[]) public creatorCollections;
    mapping(address => CreatorInfo) public creatorInfo;
    mapping(address => bool) public isCreator;

    address[] public collections;
    address[] public creators;

    address public gameToken;

    address public collectionImpl;

    uint public totalRewardAmount;

    event CollectionCreated(
        uint recordId,
        address indexed collection,
        address indexed creator
    );

    event RewardClaimed(address creator, uint availableAmount);

    constructor(address _collectionImpl) {
        collectionImpl = _collectionImpl;
    }

    function setCollectionImpl(address _collectionImpl) external {
        collectionImpl = _collectionImpl;
    }

    function createCollection(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        uint recordId
    ) external returns (address newCollection) {
        require(
            recordIdCollection[recordId] == address(0),
            "RecordId has already used"
        );

        bytes32 salt = keccak256(
            abi.encode(name, symbol, msg.sender, recordId)
        );

        newCollection = Clones.cloneDeterministic(collectionImpl, salt);
        ICollection(newCollection).initialize(name, symbol, baseTokenURI);

        recordIdCollection[recordId] = newCollection;
        creatorCollections[msg.sender].push(newCollection);
        collectionInfo[newCollection] = CollectionInfo(
            recordId,
            msg.sender,
            0
        );

        collections.push(newCollection);

        creatorInfo[msg.sender] = CreatorInfo(msg.sender, 0);

        if (isCreator[msg.sender] == false) {
            creators.push(msg.sender);
            isCreator[msg.sender] = true;
        }

        emit CollectionCreated(recordId, newCollection, msg.sender);

        return newCollection;
    }

    function getAllCollectionsLength() external view returns (uint) {
        return collections.length;
    }

    function getAllCollections() external view returns (address[] memory) {
        return collections;
    }

    function getAllCreatorsLength() external view returns (uint) {
        return creators.length;
    }

    function getAllCreators() external view returns (address[] memory) {
        return creators;
    }

    function getCollectionsByCreator(
        address creator
    ) public view returns (address[] memory) {
        return creatorCollections[creator];
    }

    function getCollectionsLengthByCreator(
        address creator
    ) public view returns (uint) {
        return creatorCollections[creator].length;
    }

    function getCollectionsFullInfoByCreator(
        address creator
    ) external view returns (CollectionInfo[] memory) {
        address[] memory allCollections = getCollectionsByCreator(creator);
        CollectionInfo[] memory collectionFullInfo = new CollectionInfo[](
            allCollections.length
        );

        for (uint i = 0; i < allCollections.length; i++) {
            collectionFullInfo[i] = collectionInfo[allCollections[i]];
        }

        return collectionFullInfo;
    }
}