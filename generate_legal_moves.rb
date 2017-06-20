def generate_legal_moves_for_man_at_x_y(file_index, rank_index, board, player, from_index)
  generated_move_list = []
  man = board.squares[from_index]
  if man != nil and man.player == player
    man.abilities.each do |ability|
      dest_x = file_index + ability.delta_x
      dest_y = rank_index + ability.delta_y
      if board.on_board?(dest_x, dest_y)
        dest_index = board.square_index_from_x_y(dest_x, dest_y)
        if not ability.slide
          if not board.squares[dest_index] # no defender
            move = Move.new(:attacking_man => man, :from_x => file_index, :from_y => rank_index, :player => man.player, :to_x => dest_x, :to_y => dest_y, :rotation => false)
            generated_move_list << move
          else
            if not board.friendly_piece?(dest_index, player) # must be an enemy
              move = Move.new(:attacking_man => man, :from_x => file_index, :from_y => rank_index, :player => man.player, :to_x => dest_x, :to_y => dest_y, :defending_man =>  board.squares[dest_index], :is_strong_attack => false)
              generated_move_list << move
            end
          end
        else
          ran_into_an_enemy = false
          dest_x = file_index + ability.delta_x
          dest_y = rank_index + ability.delta_y
          dest_index = board.square_index_from_x_y(dest_x, dest_y)
          while board.on_board?(dest_x, dest_y) and not board.friendly_piece?(dest_index, player) and not ran_into_an_enemy
            move = Move.new(:attacking_man => man, :from_x => file_index, :from_y => rank_index, :player => man.player, :to_x => dest_x, :to_y => dest_y, :defending_man =>  board.squares[dest_index], :is_strong_attack => true)
            if move.defending_man
              ran_into_an_enemy = true
            end
            generated_move_list << move
            dest_x += ability.delta_x
            dest_y += ability.delta_y
            dest_index = board.square_index_from_x_y(dest_x, dest_y)
          end
        end
      end
    end
  end
  return generated_move_list
end
