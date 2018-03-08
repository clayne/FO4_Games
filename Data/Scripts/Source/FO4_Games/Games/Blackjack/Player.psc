ScriptName Games:Blackjack:Player extends Games:Blackjack:PlayerType Hidden
import Games
import Games:Blackjack
import Games:Shared
import Games:Shared:papyrus
import Games:Shared:Deck
import Games:Shared:Log
import Games:Blackjack:Players

Card[] HandArray
SessionData Session
MatchData Match

bool Success = true const
bool Failure = false const
int Win = 21 const


; Events
;---------------------------------------------

Event OnInit()
	HandArray = new Card[0]
	Match = new MatchData
	Session = new SessionData
EndEvent


; States
;---------------------------------------------

State Starting
	Event OnState()
		Session = new SessionData
		WriteLine(self, "Sitting, "+Seating)
	EndEvent
EndState


State Wagering
	Event OnState()
		HandArray = new Card[0]
		Match = new MatchData
		Match.Bet = IWager()
		WriteLine(self, "Wagered a bet of "+Bet)
	EndEvent

	int Function IWager()
		return WagerMinimum
	EndFunction
EndState


State Dealing
	Event OnState()
		TryDraw()
		WriteLine(self, "Dealt a card..")
	EndEvent
EndState


State Playing
	Event OnState()
		{Play the next turn until a stand.}
		bool move = true const
		bool break = false const
		bool next = move

		While (next)
			Match.Turn += 1
			OnTurn(Match.Turn)

			If (IsWin(Score))
				WriteLine(self, "Standing with 21.")
				next = break

			ElseIf (IsBust(Score))
				WriteLine(self, "Busted!")
				next = break
			Else
				Match.TurnChoice = IChoice()

				If (Match.TurnChoice == ChoiceHit)
					If (TryDraw())
						WriteLine(self, "Drew a card." + Hand[HandLast])
						next = move
					Else
						WriteUnexpected(self, "Playing.OnState", "Encountered problem drawing a card!")
						next = break
					EndIf

				ElseIf (Match.TurnChoice == ChoiceStand)
					WriteLine(self, "Chose to stand.")
					next = break
				Else
					WriteUnexpectedValue(self, "Playing.OnState", "Match.TurnChoice", "The play choice "+Match.TurnChoice+" was out of range.")
					next = break
				EndIf
			EndIf
		EndWhile
	EndEvent

	int Function IChoice()
		If (Score <= 16)
			return ChoiceHit
		Else
			return ChoiceStand
		EndIf
	EndFunction
EndState


State Scoring
	Event OnState()
		If (self is Players:Dealer)
			WriteLine(self, "Skipped dealer for scoring.")
		Else
			If (IsBust(Score))
				WriteLine(self, "Score of "+Score+" is a bust.")
				OnScoring(ScoreLose)
			Else
				If (IsBust(Dealer.Score))
					WriteLine(self, "The dealer busted with "+Dealer.Score+".")
					OnScoring(ScoreWin)
				Else
					If (Score > Dealer.Score)
						WriteLine(self, "Score of "+Score+" beats dealers "+Dealer.Score+".")
						If (HasBlackjack())
							OnScoring(ScoreBlackjack)
						Else
							OnScoring(ScoreWin)
						EndIf
					ElseIf (Score < Dealer.Score)
						WriteLine(self, "Score of "+Score+" loses to dealers "+Dealer.Score+".")
						OnScoring(ScoreLose)
					ElseIf (Score == Dealer.Score)
						WriteLine(self, "Score of "+Score+" pushes dealers "+Dealer.Score+".")
						OnScoring(ScorePush)
					Else
						WriteUnexpected(self, "Scoring.OnState", "Encountered a problem handling score "+Score+" against dealers "+dealer.Score+". Refunded "+Bet+" caps.")
						OnScoring(Invalid)
					EndIf
				EndIf
			EndIf
		EndIf
	EndEvent

	Event OnScoring(int scoring)
		If (scoring == Invalid)
			Match.Winnings = 0
		ElseIf (scoring == ScoreLose)
			Match.Winnings -= Bet
			Session.Earnings -= Bet
			WriteLine(self, "Lost "+Bet+" caps.")
		ElseIf (scoring == ScoreWin)
			Match.Winnings = Bet * 2
			Session.Earnings += Winnings
			WriteLine(self, "Won "+Winnings+" caps.")
		ElseIf (scoring == ScoreBlackjack)
			Match.Winnings = Bet + (Bet * 1.5) as int
			Session.Earnings += Winnings
			WriteLine(self, "Won "+Winnings+" caps with a Blackjack.")
		ElseIf (scoring == ScorePush)
			Match.Winnings = 0
			WriteLine(self, "Pushed "+Bet+" caps.")
		Else
			WriteUnexpected(self, "OnScoring", "Scoring of "+scoring+" was unhandled.")
		EndIf
	EndEvent
EndState


State Exiting
	Event OnState()
		{Exiting}
		WriteLine(self, "Leaving")
	EndEvent
EndState


; Methods
;---------------------------------------------

Function SetScore(int value)
	{Set the players match score.}
	Match.Score = value
EndFunction


bool Function Quit()
	Session.Continue = false
	return true
EndFunction


string Function ToString()
	return Match + " " + Session
EndFunction


bool Function IsWin(int aScore)
	return aScore == Win
EndFunction


bool Function IsInPlay(int aScore)
	return aScore < Win
EndFunction


bool Function IsBust(int aScore)
	return aScore > Win
EndFunction


bool Function HasBlackjack()
	return (Score == 21 == Hand.Length == 2)
EndFunction


bool Function IsValidWager(int value)
	If (value == Match.Bet)
		return false
	ElseIf (value <= 0)
		return false
	ElseIf (value < WagerMinimum)
		return false
	ElseIf (value > WagerMaximum)
		return false
	ElseIf (value > Bank)
		return false
	Else
		return true
	EndIf
EndFunction


int Function GetBank()
	{The amount of caps the player has to gamble with.}
	return 1000
EndFunction


bool Function TryDraw()
	If (CanDraw)
		Card drawn = Cards.Deck.Draw()
		If (drawn)
			If (drawn.Reference)
				ObjectReference turnMarker = GetMarkerFor(HandLast)
				If (turnMarker)
					HandArray.Add(drawn)
					SetScore(Players.Score(self))
					Motion.Translate(drawn.Reference, turnMarker)
					return Success
				Else
					Cards.Deck.Collect(drawn)
					WriteUnexpectedValue(self, "TryDraw", "turnMarker", "The turn card marker cannot be none.")
					return Failure
				EndIf
			Else
				Cards.Deck.Collect(drawn)
				WriteUnexpectedValue(self, "TryDraw", "drawn.Reference", "Cannot draw card with a none Card.Reference.")
				return Failure
			EndIf
		Else
			WriteUnexpectedValue(self, "TryDraw", "drawn", "The draw card cannot be none.")
			return Failure
		EndIf
	Else
		WriteUnexpectedValue(self, "TryDraw", "CanDraw", "Cannot draw another card right now.")
		return Failure
	EndIf
EndFunction


ObjectReference Function GetMarkerFor(int next)
	If (Seating)
		If (next == Invalid)
			return Seating.Card01
		ElseIf (next == 0)
			return Seating.Card02
		ElseIf (next == 1)
			return Seating.Card03
		ElseIf (next == 2)
			return Seating.Card04
		ElseIf (next == 3)
			return Seating.Card05
		ElseIf (next == 4)
			return Seating.Card06
		ElseIf (next == 5)
			return Seating.Card07
		ElseIf (next == 6)
			return Seating.Card08
		ElseIf (next == 7)
			return Seating.Card09
		ElseIf (next == 8)
			return Seating.Card10
		ElseIf (next == 9)
			return Seating.Card11
		Else
			WriteUnexpectedValue(self, "NextMarker", "next", "The next marker "+next+" is out of range.")
			return none
		EndIf
	Else
		WriteUnexpectedValue(self, "NextMarker", "Seating", "Could not find a seat for the '"+Name+"' player in the array.")
		return none
	EndIf
EndFunction


; Virtual
;---------------------------------------------

int Function IWager()
	{Ask the amount of caps to wager.}
	WriteNotImplemented(self, "IWager", "Not implemented in the empty state.")
	return Invalid
EndFunction

int Function IChoice()
	{Ask the choice type for this turn.}
	WriteNotImplemented(self, "IChoice", "Not implemented in the empty state.")
	return Invalid
EndFunction

Event OnTurn(int number)
	WriteNotImplemented(self, "OnTurn", "Not implemented in the empty state.")
EndEvent

Event OnScoring(int scoring)
	WriteNotImplemented(self, "OnScoring", "Not implemented in the empty state.")
EndEvent


; Properties
;---------------------------------------------

Group Scripts
	Blackjack:Players Property Players Auto Const Mandatory
	Blackjack:Players:Dealer Property Dealer Auto Const Mandatory
	Blackjack:Players:Human Property Human Auto Const Mandatory
	Blackjack:Cards Property Cards Auto Const Mandatory
	Shared:Motion Property Motion Auto Const Mandatory
EndGroup

Group Properties
	Seat Property Seating Auto Hidden
EndGroup

Group Player
	string Property Name Hidden
		string Function Get()
			return self.GetName()
		EndFunction
	EndProperty

	int Property Turn Hidden
		int Function Get()
			return Match.Turn
		EndFunction
	EndProperty

	int Property Score Hidden
		int Function Get()
			return Match.Score
		EndFunction
	EndProperty

	int Property Bet Hidden
		int Function Get()
			return Match.Bet
		EndFunction
	EndProperty

	int Property Winnings Hidden
		int Function Get()
			return Match.Winnings
		EndFunction
	EndProperty

	int Property Earnings Hidden
		int Function Get()
			return Session.Earnings
		EndFunction
	EndProperty

	int Property Bank Hidden
		int Function Get()
			return GetBank()
		EndFunction
	EndProperty

	bool Property HasCaps Hidden
		bool Function Get()
			return Bank > 0
		EndFunction
	EndProperty

	bool Property Continue Hidden
		bool Function Get()
			return Session.Continue
		EndFunction
	EndProperty
EndGroup

Group Hand
	Card[] Property Hand Hidden
		Card[] Function Get()
			return HandArray
		EndFunction
	EndProperty

	int Property HandSize Hidden
		int Function Get()
			return HandArray.Length
		EndFunction
	EndProperty

	int Property HandLast Hidden
		int Function Get()
			return HandArray.Length - 1
		EndFunction
	EndProperty

	bool Property CanDraw Hidden
		bool Function Get()
			return IsInPlay(Score)
		EndFunction
	EndProperty
EndGroup
