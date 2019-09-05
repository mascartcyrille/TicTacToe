rm(list=ls())

PerfectPlay <- function() {
  ball <- (Sticks  - 1) %% 4
  if(ball == 0) {
    return(RandomPlay())
  } else {
    return(ball)
  }
}

RandomPlay <- function() {
  ball <- sample(x = 1:min(3, Sticks-1), size = 1)
  return(ball)
}

MachinePlay <- function() {
  ballsInBox <- sum(unlist(Boxes[[Sticks]]))
  U <- runif(1)
  ball <- ifelse(Boxes[[Sticks]]$one/ballsInBox >= U, 1, ifelse((Boxes[[Sticks]]$one + Boxes[[Sticks]]$two)/ballsInBox >= U, 2, 3))
  return(ball)
}

RandomFirst <- T
NbrGames <- 25
MaxSticks <- 16
Reward <- 1
Punishment <- -2
History <- c()
ballsUsed <- c()
Boxes <- lapply(1:MaxSticks, function(x) {
  if(x == 1) {
    list()
  } else if(x == 2) {
    list(one=10)
  } else if(x == 3) {
    list(one = 10, two = 10)
  } else {
    list(one = 10, two = 10, three = 10)
  }
})

# Learning
if(RandomFirst) {
  First <- RandomPlay
  Second <- MachinePlay
} else {
  First <- MachinePlay
  Second <- RandomPlay
}
for(games in 1:NbrGames) {
  # Game
  Sticks <- MaxSticks
  ballsUsed <- c()
  while(T) {
    # Player 1
    MachineTurn <- !RandomFirst
    Result <- First()
    if(is.na(Result)) {
      machineWon <- !RandomFirst
      break
    } else {
      ballsUsed <- c(ballsUsed, Sticks, Result)
      Sticks <- Sticks - Result
      if(Sticks == 1) {
        machineWon <- !RandomFirst
        break
      }
    }
    
    # Player 2
    MachineTurn <- RandomFirst
    Result <- Second()
    if(is.na(Result)) {
      machineWon <- !RandomFirst
      break
    } else {
      ballsUsed <- c(ballsUsed, Sticks, Result)
      Sticks <- Sticks - Result
      if(Sticks == 1) {
        machineWon <- RandomFirst
        break
      }
    }
  }
  History <- c(History, ifelse(machineWon, 1, -1))
  if(length(ballsUsed)>0) {
    for(i in seq.int(ifelse(RandomFirst, 3, 1), length(ballsUsed), 4)) {
      if(ballsUsed[i + 1] == 1) {
        Boxes[[ballsUsed[i]]]$one <- Boxes[[ballsUsed[i]]]$one + ifelse(machineWon, Reward, Punishment)
        if(Boxes[[ballsUsed[i]]]$one < 0) Boxes[[ballsUsed[i]]]$one <- 0
      } else if(ballsUsed[i + 1] == 2) {
        Boxes[[ballsUsed[i]]]$two <- Boxes[[ballsUsed[i]]]$two + ifelse(machineWon, Reward, Punishment)
        if(Boxes[[ballsUsed[i]]]$two <= 0) Boxes[[ballsUsed[i]]]$two <- 0
      } else {
        Boxes[[ballsUsed[i]]]$three <- Boxes[[ballsUsed[i]]]$three + ifelse(machineWon, Reward, Punishment)
        if(Boxes[[ballsUsed[i]]]$three <= 0) Boxes[[ballsUsed[i]]]$three <- 0
      }
    }
  }
}

png("Winning_count.png")
col <- sapply(History, function(x){ifelse(x == 1, "green", ifelse(x == -1, "red", "blue"))})
plot(cumsum(History), col=col, type = "h", xlab = "Number of games played", ylab = "#Won - #Lost", main = "Winning count (since beginning)")
dev.off()

png("Winning_rate_begining.png")
plot(x = 1:length(History), y = cumsum((History+1)%/%2)/1:length(History), col = col, xlab = "Number of games played", ylab = "#Won/#Lost", main = "Winning rate (since beginning)")
lines(c(0,length(History)), c(0.5, 0.5), type="l", col="red")
dev.off()

bin <- 4
l <- seq(1, length(History)+1, bin)
moving <- c()
for(i in 1:(length(l)-1))
  moving <- c(moving, sum((History[l[i]:(l[i+1]-1)]+1)%/%2)/(l[i+1]-l[i]))
png("Winning_rate_bin.png")
plot(x = 1:length(moving) * bin, y = moving, xlab = "Number of games played", ylab = "#Won/#Lost", main = paste("Winning rate (bin of ", bin, ")", sep = ""))
lines(c(0,length(moving)*bin), c(0.5, 0.5), type="l", col="red")
dev.off()

matrix(Boxes, nrow = 3, ncol = length(Boxes))
for(b in Boxes) {
  print(b)
}
