import numpy as np
from numpy import log as ln
import math
from otree.api import *
from datetime import datetime  #for date and time
import pytz    #for date and time
doc = """
Your app description
"""


class C(BaseConstants):
    NAME_IN_URL = 'consent'
    PLAYERS_PER_GROUP = 2  #number of participants (here wasnt necessary)
    INSTRUCTIONS_TEMPLATE = 'consent/consnet.html'
    NUM_ROUNDS = 1    #number of rounds




class Subsession(BaseSubsession):
    pass


class Group(BaseGroup):
    ttP1=models.StringField() #define for time of starting the game
    ttP2=models.StringField()  #define for time of starting the game


class Player(BasePlayer):
     prolific_id = models.StringField(default=str(" ")) #define for prolific id
     tt = models.StringField()   #start time
     is_mobile = models.BooleanField()  #to check if the user is with mobile
     offer_accepted = models.BooleanField(choices=[
        [False, 'I am not agree'],
        [True, 'I agree'],
    ])   # agree,not agree variable

# PAGES
class Demographics(Page):
    form_model = 'player'
    form_fields = ['age', 'gender', 'education', "income"]

    @staticmethod
    def before_next_page(self, timeout_happened):
        self.prolific_id = self.participant.label
pass


class consent(Page):

    form_model = 'player'
    form_fields = ['offer_accepted']

    @staticmethod
    def before_next_page(player,timeout_happened):
        player.tt = datetime.now(pytz.timezone('Europe/Berlin')).strftime("%d/%m/%Y %H:%M:%S")
        print(player.tt) #start time


class error(Page):

    @staticmethod
    def is_displayed(player: Player):
        return player.offer_accepted == False  #if the player didnt accept the consent


# PAGES
class MobileCheck(Page):   #mobile check page
    form_model = 'player'
    form_fields = ['is_mobile']

    def error_message(player: Player, values):
        if values['is_mobile']:
            return "Sorry, this experiment is not allowed with laptop and mobile phone."


class ResultsWaitPage(WaitPage):
    pass


class Results(Page):
    pass


page_sequence = [MobileCheck,consent, error] # page sequence
