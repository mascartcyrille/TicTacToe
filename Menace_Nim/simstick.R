##### Menace Nim #####
## Simulation of a Menace-kind of machine learning algorithm applied to the game of Nim.
## authors: c.mascart (mascart@i3s.unice.fr)
######################

rm(list=ls())

## Functions
# Human
RandomPlay <- function() {
  ball <- sample(x = 1:min(3, Sticks-1), size = 1)
  return(ball)
}

PerfectPlay <- function() {
  ball <- (Sticks  - 1) %% 4
  if(ball == 0) {
    return(RandomPlay())
  } else {
    return(ball)
  }
}

# Machine
MachinePlay <- function() {
  ballsInBox <- sum(unlist(Boxes[[Sticks]]))
  U <- runif(1)
  ball <- ifelse(Boxes[[Sticks]]$one/ballsInBox >= U, 1, ifelse((Boxes[[Sticks]]$one + Boxes[[Sticks]]$two)/ballsInBox >= U, 2, 3))
  return(ball)
}

## Parameters
# Players
vsPerfect <- T
MachineFirst <- T
NbrGames <- 1000
# Setup
MaxSticks <- 11
Reward <- 3
Punishment <- -3
# Machine
History <- c()
ballsUsed <- c()
Boxes <- lapply(1:MaxSticks, function(x) {
  if(x == 1) {
    list()
  } else if(x == 2) {
    list(one=3)
  } else if(x == 3) {
    list(one = 3, two = 3)
  } else {
    list(one = 3, two = 3, three = 3)
  }
})
# Plotting
bin <- 100

## Learning
if(MachineFirst) {
  First <- MachinePlay
  Second <- ifelse(vsPerfect, PerfectPlay, RandomPlay)
} else {
  First <- ifelse(vsPerfect, PerfectPlay, RandomPlay)
  Second <- MachinePlay
}
for(games in 1:NbrGames) {
  # Game
  Sticks <- MaxSticks
  ballsUsed <- c()
  while(T) {
    # Player 1
    MachineTurn <- MachineFirst
    Result <- First()
    if(is.na(Result)) {
      machineWon <- MachineFirst
      break
    } else {
      ballsUsed <- c(ballsUsed, Sticks, Result)
      Sticks <- Sticks - Result
      if(Sticks == 1) {
        machineWon <- MachineFirst
        break
      }
    }
    
    # Player 2
    MachineTurn <- !MachineFirst
    Result <- Second()
    if(is.na(Result)) {
      machineWon <- !MachineFirst
      break
    } else {
      ballsUsed <- c(ballsUsed, Sticks, Result)
      Sticks <- Sticks - Result
      if(Sticks == 1) {
        machineWon <- !MachineFirst
        break
      }
    }
  }
  History <- c(History, ifelse(machineWon, 1, -1))
  if(length(ballsUsed)>0) {
    for(i in seq.int(ifelse(MachineFirst, 1, 3), length(ballsUsed), 4)) {
      if(ballsUsed[i + 1] == 1) {
        Boxes[[ballsUsed[i]]]$one <- Boxes[[ballsUsed[i]]]$one + ifelse(machineWon, Reward, Punishment)
        if(Boxes[[ballsUsed[i]]]$one < 1) Boxes[[ballsUsed[i]]]$one <- 1
      } else if(ballsUsed[i + 1] == 2) {
        Boxes[[ballsUsed[i]]]$two <- Boxes[[ballsUsed[i]]]$two + ifelse(machineWon, Reward, Punishment)
        if(Boxes[[ballsUsed[i]]]$two <= 1) Boxes[[ballsUsed[i]]]$two <- 1
      } else {
        Boxes[[ballsUsed[i]]]$three <- Boxes[[ballsUsed[i]]]$three + ifelse(machineWon, Reward, Punishment)
        if(Boxes[[ballsUsed[i]]]$three <= 1) Boxes[[ballsUsed[i]]]$three <- 1
      }
    }
  }
}

## Displaying results
# Winning count: the number of games won minus the number of games lost
png("Winning_count.png")
col <- sapply(History, function(x){ifelse(x == 1, "green", ifelse(x == -1, "red", "blue"))})
plot(cumsum(History)
     , col=col, type = "h"
     , xlab = "Number of games played", ylab = "#Won - #Lost", main = "Winning count (since beginning)")
dev.off()

png("Winning_rate_begining.png")
plot(x = 1:NbrGames, y = cumsum((History+1)%/%2)/1:NbrGames
     , ylim = c(0.0, 1.0)
     , col = col, xlab = "Number of games played", ylab = "#Won/#Games", main = "Winning rate (since beginning)")
lines(c(0,length(History)), c(0.5, 0.5), type="l", col="red")
dev.off()

moving <- c()
for(i in 1:(NbrGames-bin+1)) {
  moving <- c(moving, sum((History[i:(i+bin-1)]+1)%/%2)/bin)
}
png("Winning_rate_bin.png")
plot(x = bin:NbrGames, y = moving
     , ylim = c(0.0, 1.0)
     , xlab = "Number of games played", ylab = "#Won/#Lost", main = paste("Winning rate (bin of ", bin, ")", sep = "")
     , type = "l")
lines(c(0,length(moving)*bin), c(0.5, 0.5), type="l", col="red")
dev.off()
