#!/usr/bin/env python3

def Guild ():
    return {"guild_id": None, "guild_name": "", "guild_shortname": "", "guild_roster": ""}

def Raffle ():
    return {"raffle_id": None, "raffle_guild": 0, "raffle_guild_num": 0, "raffle_time": "", "raffle_ticket_cost": "", "raffle_closed": 0, "raffle_notes": ""}

def User ():
    return {"user_id": None, "user_name": ""}

def Ticket ():
    return {"ticket_id": None, "ticket_raffle": 0, "ticket_user": 0, "ticket_count": 0, "ticket_timestamp": 0}

def Prize ():
    return {"prize_id": None, "prize_raffle": 0, "prize_text": "", "prize_text2": "", "prize_winner": 0, "prize_finalised": 0, "prize_value": None, "prize_style": "standard"}
