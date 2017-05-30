ScriptName Gambling:BlackJack:Competitors:PlayerC extends Gambling:BlackJack:Competitors:Seat
import Gambling
import Gambling:Common
import Gambling:Shared


; Methods
;---------------------------------------------

Event OnStartup()
	ID = 3
	Abort = false
	Score = 0
	Wager = 0
	Winnings = 0
	Hand = new CardDeck:Card[0]
EndEvent


Event OnDeal(CardDeck:Card card, int index)
	If (card)
		If (card.Reference)
			If (index == 0)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C01)
			ElseIf (index == 1)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C02)
			ElseIf (index == 2)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C03)
			ElseIf (index == 3)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C04)
			ElseIf (index == 4)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C05)
			ElseIf (index == 5)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C06)
			ElseIf (index == 6)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C07)
			ElseIf (index == 7)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C08)
			ElseIf (index == 8)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C09)
			ElseIf (index == 9)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C10)
			ElseIf (index == 10)
				Controller.Translate(card.Reference, Gambling_BlackJack_P3C11)
			Else
				WriteLine(self, "The hand index '"+index+"' is out of range.")
			EndIf
		Else
			WriteLine(self, "Cannot deal a none card reference.")
		EndIf
	Else
		WriteLine(self, "Cannot deal a none card.")
	EndIf
EndEvent


Event OnPlay()
	If (Turn == 1)
		If (BlackJack.IsWin(Score))
			WriteLine(self, "The seat '"+ID+"' has a black jack on turn one.")
			return
		Else
			int selected = OptionChoice()

			If (selected == OptionHit)
				WriteLine(self, "The seat '"+ID+"' has chosen to hit with "+Score)
				Deal(BlackJack.Cards.Deck.Draw())
				self.OnPlay()

			ElseIf (selected == OptionStand)
				WriteLine(self, "The seat '"+ID+"' has chosen to stand with "+Score)
				return
			Else
				WriteLine(self, "The option '"+selected+"' is unhandled.")
				return
			EndIf
		EndIf

	ElseIf (Turn >= 2)
		If (BlackJack.IsWin(Score))
			WriteLine(self, "The seat '"+ID+"' has a black jack with "+Score)
			return

		ElseIf (BlackJack.IsBust(Score))
			WriteLine(self, "The seat '"+ID+"' has busted with "+Score)
			return

		Else
			CardDeck:Card card = Hand[Turn]
			int selected = OptionChoice()

			If (selected == OptionHit)
				WriteLine(self, "The seat '"+ID+"' has chosen to hit with "+Score)
				Deal(BlackJack.Cards.Deck.Draw())
				self.OnPlay()

			ElseIf (selected == OptionStand)
				WriteLine(self, "The seat '"+ID+"' has chosen to stand with "+Score)
				return

			Else
				WriteLine(self, "The option '"+selected+"' is unhandled.")
				return
			EndIf
		EndIf
	EndIf
EndEvent


; Functions
;---------------------------------------------

int Function OptionChoice()
	If (Score <= 16)
		return OptionHit
	Else
		return OptionStand
	EndIf
EndFunction



; Properties
;---------------------------------------------

Group Cards
	ObjectReference Property Gambling_BlackJack_P3C01 Auto Const Mandatory
	ObjectReference Property Gambling_BlackJack_P3C02 Auto Const Mandatory
	ObjectReference Property Gambling_BlackJack_P3C03 Auto Const Mandatory
	ObjectReference Property Gambling_BlackJack_P3C04 Auto Const Mandatory
	ObjectReference Property Gambling_BlackJack_P3C05 Auto Const Mandatory
	ObjectReference Property Gambling_BlackJack_P3C06 Auto Const Mandatory
	ObjectReference Property Gambling_BlackJack_P3C07 Auto Const Mandatory
	ObjectReference Property Gambling_BlackJack_P3C08 Auto Const Mandatory
	ObjectReference Property Gambling_BlackJack_P3C09 Auto Const Mandatory
	ObjectReference Property Gambling_BlackJack_P3C10 Auto Const Mandatory
	ObjectReference Property Gambling_BlackJack_P3C11 Auto Const Mandatory
EndGroup
