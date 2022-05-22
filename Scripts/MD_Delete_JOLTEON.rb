def deleteSpecies2(species, form="any")
	#delete the first Pokémon in the party of the given species
	for i in 0...$Trainer.pokemonParty.length
		if ($Trainer.pokemonParty[i]!=nil) && ($Trainer.pokemonParty[i].species == species) &&
				($Trainer.pokemonParty[i].form == form || $Trainer.pokemonParty[i].form == "any") &&
				!$Trainer.pokemonParty[i].egg?
			#if only one Pokémon is in the party send message and return
			if $Trainer.pokemonParty.length == 1
				Kernel.pbMessage("You only have one Pokémon!") #show the message
				return false #end the function
			else
				pbAddPokemonSilent(:GENGAR,$Trainer.party[i].level)
        pbRemovePokemonAt(i) #delete the mon
				return true #end function and return that the Pokémon was deleted
			end
		end
	end
	return false #return that no Pokémon was deleted
end