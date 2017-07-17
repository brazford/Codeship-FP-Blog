- (NSMutableArray *) generateLegalMovesForManAtX: (int) x Y: (int) y board: (EFCBoard *) board player: (EFCPlayer *) player fromIndex: (int) fromIndex
{
    NSMutableArray *generatedMoves = [[NSMutableArray alloc] init];
    if(board.squares[fromIndex] != [NSNull null])
    {
        EFCMan *man = (EFCMan *) board.squares[fromIndex];
        if([man.player.name isEqualToString: player.name])
        {
            // add rotation moves to any wounded piece except Knight-like pieces
            // for now, we allow anything that's not a "pure" Knight to rotate
            // but maybe we should allow wounded knights to rotate?
            if(man.wounds > 0)
            {
                if(man.piece.name.length < 6 || ![[man.piece.name substringWithRange:NSMakeRange(0, 5)] isEqualToString:@"Knight"])
                {
                    EFCMove *rotate_left_move = [[EFCMove alloc] init];
                    rotate_left_move.attacking_man = man;
                    rotate_left_move.from_x = x;
                    rotate_left_move.from_y = y;
                    rotate_left_move.to_x = x;
                    rotate_left_move.to_y = y;
                    rotate_left_move.special_move_type = ROTATE_LEFT;
                    [generatedMoves addObject:rotate_left_move];
                    EFCMove *rotate_right_move = [[EFCMove alloc] init];
                    rotate_right_move.attacking_man = man;
                    rotate_right_move.from_x = x;
                    rotate_right_move.from_y = y;
                    rotate_right_move.to_x = x;
                    rotate_right_move.to_y = y;
                    rotate_right_move.special_move_type = ROTATE_RIGHT;
                    [generatedMoves addObject:rotate_right_move];
                }
            }
            if(man.tool == EXPLOSIVE)
            {
                EFCMove *detonation_move = [[EFCMove alloc] init];
                detonation_move.attacking_man = man;
                detonation_move.from_x = x;
                detonation_move.from_y = y;
                detonation_move.to_x = x;
                detonation_move.to_y = y;
                detonation_move.special_move_type = DETONATION_MOVE;
                [generatedMoves addObject:detonation_move];
            }
            for(EFCAbility *ability in man.abilities)
            {
                int dest_x = x + ability.delta_x;
                int dest_y = y + ability.delta_y;
                int dest_index = [board squareIndexFromX:dest_x Y:dest_y];
                if(!ability.slide)
                {
                    /*if(dest_x == 5 && dest_y == 3)
                    {
                        dest_x = 5;
                    }*/
                    if([board isOnBoardX:dest_x Y:dest_y] && [board isLegalSquareType:((EFCSquareType *) board.squareTypes[dest_index]) forMan:man])
                    {
                        EFCMove *move = [[EFCMove alloc] init];
                        move.attacking_man = man;
                        move.from_x = x;
                        move.from_y = y;
                        move.to_x = dest_x;
                        move.to_y = dest_y;
                        move.jump = ability.jump;
                        /*
                        if(move.to_x == 3 && move.to_y == 1)
                        {
                            move.to_x = 3;
                        }
                        */
                        BOOL addThisMove = false;
                        if(board.squares[dest_index] == [NSNull null])
                        {
                            addThisMove = true;
                        }
                        else
                        {
                            if(![board isFriendlyPieceAtIndex:dest_index player:player])
                            {
                                addThisMove = true;
                                move.defending_man = board.squares[dest_index];
                            }
                        }
                        if(addThisMove)
                        {
                            [generatedMoves addObject:move];
                        }
                    }
                }
                else
                {
                    BOOL ranIntoAnEnemy = false;
                    while([board isOnBoardX:dest_x Y:dest_y] && ![board isFriendlyPieceAtIndex:dest_index player:player] && !ranIntoAnEnemy && [board isLegalSquareType:((EFCSquareType *) board.squareTypes[dest_index]) forMan:man])
                    {

                        EFCMove *slideMove = [[EFCMove alloc] init];
                        slideMove.attacking_man = man;
                        slideMove.from_x = x;
                        slideMove.from_y = y;
                        slideMove.to_x = dest_x;
                        slideMove.to_y = dest_y;
                        if([board isEnemyPieceAtIndex:dest_index player:player])
                        {
                            ranIntoAnEnemy = true;
                            slideMove.is_strong_attack = true;
                            slideMove.defending_man = board.squares[dest_index];
                        }
                        else if([board isShovelableOrBulldozerable:((EFCSquareType *) board.squareTypes[dest_index]) forMan:man])
                        {
                            ranIntoAnEnemy = true;
                        }
                        [generatedMoves addObject:slideMove];
                        dest_x += ability.delta_x;
                        dest_y += ability.delta_y;
                        dest_index = [board squareIndexFromX:dest_x Y:dest_y];
                    }
                }
            }
        }
    }
    return generatedMoves;
}
