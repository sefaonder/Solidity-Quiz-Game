// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // ERC20 Token Transfer
import "@openzeppelin/contracts/utils/Counters.sol";


contract QuizGame{

 using Counters for Counters.Counter;

 event Launch(
        uint id,
        address indexed creator,
        uint endAt,
        string uri,
        uint price
    );
    event GuessLose(uint indexed id, address indexed caller, uint price);
    event GuessWin(uint indexed id, address indexed caller, uint price);

    event CancelQuiz(uint indexed id, address indexed caller);
    event Claim(uint id,uint pledged);


    struct Quiz {
        address creator;        // creator of quiz
        bytes32 quizAnswerHash; // store correct answer hash in storage
        uint price;             // min price to guess the word
        uint pledged;           // pledged amount 
        uint startAt;           // default block.timestamp (current time)
        uint endAt;             // max 90 days
        string uri;             // uri for quiz.It contains question ,description and image etc.
        address winner;         // winner of the quiz.If a quiz has a winner wouldn't users guess and creator can't claim pledged money.
    }

    IERC20 public immutable token;
    // Total count of quizes created.
    // It is also used to generate id for new quizes.
    Counters.Counter private quizCounter;
    // Mapping from id to Quiz
    mapping(uint => Quiz) public quizes;
    // store all quiz and return them if necessary
    Quiz[] allQuizes;


    constructor(address _token) {
        token = IERC20(_token);
    }

    modifier checkisPlayable(uint _id){
        Quiz memory quiz = quizes[_id];

        require(block.timestamp <= quiz.endAt, "ended");
        require(quiz.creator != msg.sender,"you cant play own game");
        require(quiz.winner != address(0),"Quiz has been answered");
        _;
    }

    modifier checkTheAnswerValid(bytes32 _quizAnswerHash){
        string memory empty = "";
        require(_quizAnswerHash != keccak256(abi.encodePacked(empty)),"must have a valid answer");
        _;
    }


    function launch(
        bytes32 _quizAnswerHash,
        uint _endAt,
        uint _price,
        string calldata _uri
    ) external checkTheAnswerValid(_quizAnswerHash) {
        require(_endAt >= block.timestamp, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        Quiz memory quiz;
        quiz.creator = msg.sender;
        quiz.quizAnswerHash= _quizAnswerHash;
        quiz.price=_price;
        quiz.pledged= 0;
        quiz.startAt= block.timestamp;
        quiz.endAt= _endAt;
        quiz.uri=_uri;
        quiz.winner;


        quizes[quizCounter.current()] = quiz;
        allQuizes.push(quiz);


        quizCounter.increment();

        emit Launch(quizCounter.current(), msg.sender,_endAt,_uri,_price);
    }

    function guess(uint _id,string calldata _answer) external payable checkisPlayable(_id) {
        Quiz storage quiz = quizes[_id];
        require(msg.value >= quiz.price,"sended money not enough");
        
        quiz.pledged += quiz.price;
        // if answer hash and quizAnswerHash matches player win and earn all pledged money inside
        if(keccak256(abi.encodePacked(_answer)) == quiz.quizAnswerHash){
            quiz.winner = msg.sender;
            token.transferFrom(msg.sender, address(this), quiz.pledged);
            emit GuessWin(_id, msg.sender, quiz.pledged);

        }
        // push the new quiz to array
        allQuizes[_id] = quiz;

        emit GuessLose(_id, msg.sender, quiz.price);
    }

    function claimMoney(uint _id) external {
        Quiz storage quiz = quizes[_id];
        require(msg.sender == quiz.creator,"Only claim your own game");
        require(block.timestamp < quiz.endAt,"The quiz must be finished");
        require(quiz.winner != address(0),"Quiz has been answered");

        token.transfer(quiz.creator, quiz.pledged);
        // That not best solition maybe define a bool varible like 'claimed' in Quiz struct
        quiz.winner = quiz.creator;
        // push the new quiz to array
        allQuizes[_id] = quiz;

        emit Claim(_id,quiz.pledged);
    }

    
    function viewAllQuizes() public view returns(Quiz[] memory){
        return allQuizes;
    }

}
