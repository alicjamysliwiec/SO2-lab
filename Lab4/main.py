import os
import time
import math
from itertools import chain


class TicTacToe:
    def __init__(self) -> None:
        self.board_template = """
         A   B   C
      
      1  {} ║ {} ║ {} 
        ═══╬═══╬═══
      2  {} ║ {} ║ {} 
        ═══╬═══╬═══
      3  {} ║ {} ║ {} 
      """

        self.game_state = [[" ", " ", " "], [" ", " ", " "], [" ", " ", " "]]
        self.markers = {"player": None, "computer": None}
        self.score = {"player": 0, "computer": 0, "ties": 0}
        self.player_turn = True
    
    def start(self):
      error = ""
      end_of_round = False
      who_started_first = "player"

      while True:
        answer = input("Select a marker ('X' or 'O'): ")
        if answer in ("X", "x"):
          self.markers["player"] = "X"
          self.markers["computer"] = "O"
          break
        elif answer in ("O", "o"):
          self.markers["player"] = "O"
          self.markers["computer"] = "X"
          break
        else:
          print("Invalid marker, try again!")

      while True:
        self._display_board()

        if self._is_winning(self.game_state, self.markers["computer"]):
            print("Computer won!")
            self.score["computer"] += 1
            end_of_round = True
        elif self._is_winning(self.game_state, self.markers["player"]):
            print("Player won!")
            self.score["player"] += 1
            end_of_round = True
        elif self._no_more_moves(self.game_state):
            print("Tie!")
            self.score["ties"] += 1
            end_of_round = True

        if end_of_round:
          while True:
            answer = input("Do you want to continue? [y/n]: ")
            if answer in ("Y", "y"):
              self.game_state = [[" ", " ", " "], [" ", " ", " "], [" ", " ", " "]]
              end_of_round = False
              if who_started_first == "player":
                self.player_turn = False
                who_started_first = "computer"
              else:
                self.player_turn = True
                who_started_first = "player"
              break
            elif answer in ("N", "n"):
              quit()
            else:
              print("Invalid answer!")

          continue
            
        if self.player_turn:
            print(error)
            move = input("Enter your move (example - A2): ")
            move = self._translate_move(move)

            if move is None:
              error = "Invalid move syntax, try again!"
            elif self.game_state[move[0]][move[1]] != " ":
              error = "Move already played, try again!"
            else:
              self.game_state[move[0]][move[1]] = self.markers["player"]
              self.player_turn = False
              error = ""
        else:
          best_move = self._decide_best_move()
          time.sleep(1)
          self.game_state[best_move[0]][best_move[1]] = self.markers["computer"]
          self.player_turn = True
        
    def _display_board(self):
        os.system("cls" if os.name == "nt" else "clear")
        print("Score")
        print("=====================")
        print(f"Player: {self.score['player']}, Computer: {self.score['computer']}, Ties: {self.score['ties']}")
        print("=====================")
        print("Player's" if self.player_turn else "Computer's", "turn")
        _game_state = list(chain.from_iterable(self.game_state))  # 2D list -> 1D list
        print(self.board_template.format(*_game_state))

    def _translate_move(self, move):
      translated_move = [None, None]

      if move is None or len(move) != 2:
        return None

      if move[0] in ("A", "a"):
        translated_move[1] = 0
      elif move[0] in ("B", "b"):
        translated_move[1] = 1
      elif move[0] in ("C", "c"):
        translated_move[1] = 2
      else:
        return None

      if move[1] in ("1", "2", "3"):
        translated_move[0] = int(move[1])-1
      else:
        return None

      return translated_move

    def _is_winning(self, game_state, marker):
        for i in range(3):
            if (
                game_state[i][0] == marker
                and game_state[i][1] == marker
                and game_state[i][2] == marker
            ) or (
                game_state[0][i] == marker
                and game_state[1][i] == marker
                and game_state[2][i] == marker
            ):
                return True
        if (
            game_state[0][0] == marker
            and game_state[1][1] == marker
            and game_state[2][2] == marker
        ) or (
            game_state[0][2] == marker
            and game_state[1][1] == marker
            and game_state[2][0] == marker
        ):
            return True

        return False

    def _no_more_moves(self, game_state):
        for i in range(3):
            for j in range(3):
                if game_state[i][j] == " ":
                    return False

        return True

    def _minimax(self, current_turn, game_state):
        if self._is_winning(game_state, self.markers["computer"]):
            return 1
        elif self._is_winning(game_state, self.markers["player"]):
            return -1
        elif self._no_more_moves(game_state):
            return 0

        if current_turn == "computer":
            best_score = -math.inf
            for i in range(3):
                for j in range(3):
                    if game_state[i][j] == " ":
                        game_state[i][j] = self.markers["computer"]
                        score = self._minimax("player", game_state.copy())
                        game_state[i][j] = " "
                        if score > best_score:
                            best_score = score
        else:
            best_score = math.inf
            for i in range(3):
                for j in range(3):
                    if game_state[i][j] == " ":
                        game_state[i][j] = self.markers["player"]
                        score = self._minimax("computer", game_state.copy())
                        game_state[i][j] = " "
                        if score < best_score:
                            best_score = score

        return best_score

    def _decide_best_move(self):
        _game_state = self.game_state
        best_score = -math.inf
        best_move = None

        for i in range(3):
            for j in range(3):
                if _game_state[i][j] == " ":
                    _game_state[i][j] = self.markers["computer"]
                    score = self._minimax("player", _game_state.copy())
                    _game_state[i][j] = " "
                    if score > best_score:
                        best_score = score
                        best_move = (i, j)

        return best_move


if __name__ == "__main__":
    os.system("cls" if os.name == "nt" else "clear")
    game = TicTacToe()
    game.start()
