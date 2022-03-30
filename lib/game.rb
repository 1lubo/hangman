require 'json'

ULS = "\e[4m" # underline start
ULE = "\e[24m" # underline end
GREEN = "\e[32m"
PURPLE = "\e[35m"
RED = "\e[31m"
BOLDS = "\e[1m" # bold start
BOLDE = "\e[22m" # bold end
COLORE = "\e[0m" # reset color mode



module Display 

    def show_display(word, letters, attempts)
    puts "#{PURPLE}"+"#" * 150 + "#{COLORE}"       
    puts "\n#{BOLDS}Word#{BOLDE} \t \t \t #{BOLDS}Attempts remaining: #{attempts} #{BOLDE}\n #{word} \n \n#{BOLDS}Letters Guessed:#{BOLDE} \n#{letters} "
    end
end



class Game
    attr_accessor :word, :attempts_left, :letters_guessed, :word_to_letters, :win

    SaveFolderName = '../saves/'
    SaveName = 'save.txt'

    RULES = "\n#{BOLDS}Hangman is a guessing game. The computer will pick a word between 5-10 characters and you will try to guess it by suggesting letters. You have 12 chances to guess incorectly. #{BOLDE}"

    include Display

    def initialize
        @word = get_word().chomp
        @word_to_letters = self.word.split('')
        @letters_guessed = []
        @attempts_left = 12
        @win = false
    end

    def deserialize(string)
        game_hash = JSON.parse(string)
    end

    def serialize
        {'word' => self.word, 'to_letters' => self.word_to_letters, 'guessed' => self.letters_guessed, 'attempts' => self.attempts_left}.to_json
    end

    def to_s
        "Game: Word: #{self.word} letters guessed: #{letters_guessed}. Attempts left: #{attempts_left}"
    end

    def attempts_left
        @attempts_left
    end

    def word
        @word
    end

    def letters_guessed
        @letters_guessed
    end

    def check_win
        self.win = self.word_to_letters.length == 0
    end
    def decrease_attempts
        self.attempts_left -= 1
    end

    def load_word(word)
        self.word = word
    end

    def load_letters(letters)
        self.letters_guessed = letters
    end

    def get_word()
        lines = File.readlines('../10000_words.txt')
        return lines.select {|word| word.length >= 5 && word.length <= 10}.sample
    end

    def get_next_letter
        letter = 0
        while letter.ord < 97 || letter.ord > 122
            puts "Please enter a letter. \t (Enter 'save' to save the game and exit)"
            letter = gets.chomp.downcase
            if self.letters_guessed.include?(letter)
                puts "You've already tried this"
                letter = 0
                next
            elsif letter.ord == 32
                next 
            elsif letter == 'save'
                self.save_game
                return letter
            end
        end

        self.letters_guessed.push(letter)
        return letter
        
    end

    def draw_guessed_letters
        string = ''
        self.letters_guessed.each do |char|  
            if self.word.include?(char)
                string += "#{ULS}#{BOLDS}#{GREEN} #{char} #{ULE} "
            else
                string += "#{ULS}#{BOLDS}#{RED} #{char} #{ULE} " 
            end
        end

        return string + COLORE
    end

    def draw_word
        string = ''
        self.word.each_char do |char|  
            if self.letters_guessed.include?(char)
                string += "#{ULS}#{BOLDS}#{GREEN} #{char} #{ULE} "
            else
                string += "#{ULS}#{BOLDS}#{GREEN}  #{ULE} " 
            end
        end

        return string + COLORE
    end
    
    def start
        
        want_to_play = ''
        acceptable_answers = ['yes', 'no', 'load']
        puts "Would you like to play hangman?"
        puts "Please answer: \n'yes' - to start a new game \n'load' - to load a saved game \n'no' - to quit"  

        while !acceptable_answers.include?(want_to_play )
            puts "Please choose one of the above options"  
            want_to_play = gets.chomp.downcase
        end

        want_to_play
    end

    def save_game

        if Dir.exist?(SaveFolderName)
            puts "Save folder already exists. Saving file"            
        else
            puts "Save folder does not exist"
            puts "Creating save folder"            
            Dir.mkdir(SaveFolderName)
        end

        File.open("#{SaveFolderName}#{SaveName}", "w"){ |somefile| somefile.puts self.serialize }
    end

    def load_game
        
        if File.exist?("#{SaveFolderName}#{SaveName}")
            
            contents = File.open("#{SaveFolderName}#{SaveName}", "r"){ |file| file.read }
            return self.deserialize(contents)
        else
            puts `clear`
            puts "#{BOLDS}No save file exists yet#{BOLDE}"
            puts
            return false
        end
    end

    def play()
        start = self.start

        if start == 'no'
            puts `clear`
            puts "#{BOLDS}See ya next time!#{BOLDE}"
            return
        end
        
        if start == 'yes'
            puts `clear`
            puts RULES
        end
        
        if start == 'load'
            saved_game = self.load_game

            if !saved_game
                self.play
            else
                
                self.word = saved_game.fetch('word')
                self.attempts_left = saved_game.fetch('attempts')
                self.word_to_letters = saved_game.fetch('to_letters')
                self.letters_guessed = saved_game.fetch('guessed')
                
            end
        end

        while self.attempts_left > 0 || self.win
            puts `clear`
            self.show_display(self.draw_word, self.draw_guessed_letters, self.attempts_left)
            guess = self.get_next_letter

            if guess == 'save'
                puts `clear`
                puts "#{BOLDS}See ya next time#{BOLDE}" 
                return
            end

            if !self.word.include?(guess)
                self.attempts_left -= 1
            else
                self.word_to_letters.select! {|c| c != guess}
            end
            
            self.check_win            

            if self.win
                puts `clear`
                puts "#{BOLDS}YOU WIN#{BOLDE}"
                puts
                puts self.draw_word
                return
            end
            
        end
        puts `clear`
        puts "Better luck next time! The word you were trying to guess was #{BOLDS}#{self.word}"
        
    end

    private
    def word=(word)
        @word = word
    end

    def attempts_left=(attempts_left)
        @attempts_left = attempts_left
    end

    def letters_guessed=(letters_guessed)
        @letters_guessed = letters_guessed
    end

end





Game.new.play