//SPDX-License-Identifier:MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomWinnerGame is VRFConsumerBase, Ownable {
    ///@dev Amount of Link to send with the request
    uint256 public fee;

    ///@dev ID of public key against which randomness is generated
    bytes32 public keyHash;

    ///@dev Addresses of the players
    address[] public players;

    ///@dev Max number of players in one game
    uint8 maxPlayers;

    ///@dev Did game start
    bool public gameStarted;

    ///@dev Fees to enter per game
    uint256 entryFee;

    ///@dev Current Game ID
    uint256 public gameId;

    ///@dev Emitted when the game starts
    event GameStarted(uint256 gameId, uint8 maxPlayers, uint256 entryFee);

    ///@dev Emitted when someone joins the game
    event PlayerJoined(uint256 gameId, address player);

    ///@dev Emitted when the game ends
    event GameEnded(uint256 gameId, address winner, bytes32 requestId);

    ///@dev Called when the contract is started
    ///@param vrfCoordinator Address of the VRFCoordinator contract
    ///@param linkToken Address of LINK token contract
    ///@param vrfKeyHash The amount of LINK to send with the request
    ///@param vrfFee ID of the public key against which randomness is generated
    constructor(
        address vrfCoordinator,
        address linkToken,
        bytes32 vrfKeyHash,
        uint256 vrfFee
    ) VRFConsumerBase(vrfCoordinator, linkToken) {
        keyHash = vrfKeyHash;
        fee = vrfFee;
        gameStarted = false;
    }

    ///@dev Game starts
    function startGame(uint8 _maxPlayers, uint256 _entryFee) public onlyOwner {
        require(!gameStarted, "Game is currently running");
        // Empty the players array
        delete players;
        maxPlayers = _maxPlayers;
        gameStarted = true;
        entryFee = _entryFee;
        gameId++;
        emit GameStarted(gameId, maxPlayers, entryFee);
    }

    ///@dev Join Game if its started
    function joinGame() public payable {
        require(gameStarted, "Game has not been started yet");
        require(msg.value == entryFee, "Incorrect Amount paid");
        require(players.length < maxPlayers, "Game is full");

        players.push(msg.sender);
        emit PlayerJoined(gameId, msg.sender);

        if (players.length == maxPlayers) {
            getRandomWinner();
        }
    }

    ///@dev Overriding function from Chainlink which recives the valid VRF proof.
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        uint256 winnerIndex = randomness % players.length;
        address winner = players[winnerIndex];
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ether");
        emit GameEnded(gameId, winner, requestId);
        gameStarted = false;
    }

    ///@dev Private Funtion that runs only if there sufficient LINK tokens
    function getRandomWinner() private returns (bytes32) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        return requestRandomness(keyHash, fee);
    }

    receive() external payable {}

    fallback() external payable {}
}
