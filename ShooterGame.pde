import processing.core.PShape;
import processing.core.PApplet;

void setup() {
  size(1920, 1080);
  player = new Player();
  for (int i = 0; i < MAX_ENEMIES; i++) {
    enemies[i] = new Enemy();
  }
  for (int i = 0; i < MAX_BULLETS; i++) {
    playerBullets[i] = new Bullet(-100, -100, 0);
    enemyBullets[i] = new Bullet(-100, -100, 0);
  }
  frameRate(60);
}

void draw() {
  background(0);
  drawPlayer();
  drawEnemies();
  drawBullets();
  checkInput();
  checkMouseInput();
  checkCollisions();
  move();
  drawGUI();
}

void drawPlayer() {
  playerShape = createShape();
  playerShape.beginShape();
  playerShape.noStroke();
  playerShape.fill(player.getColor());
  playerShape.vertex(player.x, player.y);
  playerShape.vertex(player.x + player.width, player.y);
  playerShape.vertex(player.x + player.width, player.y + player.height);
  playerShape.vertex(player.x, player.y + player.height);
  playerShape.endShape(CLOSE);
  playerShape.addChild(createShape(ELLIPSE, 0, 0, player.width / 2, player.height / 2));
  playerShape.addChild(createShape(ELLIPSE, player.width, 0, player.width / 2, player.height / 2));
  shape(playerShape, player.x, player.y);
}

void drawEnemies() {
  for (int i = 0; i < MAX_ENEMIES; i++) {
    Enemy enemy = enemies[i];
    if (enemy.isAlive()) {
      enemyShape = createShape();
      enemyShape.beginShape();
      enemyShape.noStroke();
      enemyShape.fill(enemy.getColor());
      enemyShape.vertex(enemy.x, enemy.y);
      enemyShape.vertex(enemy.x + enemy.width, enemy.y);
      enemyShape.vertex(enemy.x + enemy.width, enemy.y + enemy.height);
      enemyShape.vertex(enemy.x, enemy.y + enemy.height);
      enemyShape.endShape(CLOSE);
      enemyShape.addChild(createShape(ELLIPSE, 0, 0, enemy.width / 2, enemy.height / 2));
      enemyShape.addChild(createShape(ELLIPSE, enemy.width, 0, enemy.width / 2, enemy.height / 2));
      shape(enemyShape, enemy.x, enemy.y);
    }
  }
}

void drawBullets() {
  for (int i = 0; i < MAX_BULLETS; i++) {
    Bullet bullet = playerBullets[i];
    if (bullet.isAlive()) {
      bulletShape = createShape(ELLIPSE, 0, 0, bullet.width, bullet.height);
      bulletShape.setFill(bullet.getColor());
      shape(bulletShape, bullet.x, bullet.y);
    }
  }
  for (int i = 0; i < MAX_BULLETS; i++) {
    Bullet bullet = enemyBullets[i];
    if (bullet.isAlive()) {
      bulletShape = createShape(ELLIPSE, 0, 0, bullet.width, bullet.height);
      bulletShape.setFill(bullet.getColor());
      shape(bulletShape, bullet.x, bullet.y);
    }
  }
}

void move() {
  if (keyPressed) {
    if (key == 'a' || key == 'A') {
      player.move(-5, 0);
    } else if (key == 'd' || key == 'D') {
      player.move(5, 0);
    } else if (key == 'w' || key == 'W') {
      player.move(0, -5);
    } else if (key == 's' || key == 'S') {
      player.move(0, 5);
    }
  }
  for (int i = 0; i < MAX_ENEMIES; i++) {
    enemies[i].move();
  }
  for (int i = 0; i < MAX_BULLETS; i++) {
    playerBullets[i].move();
  }
  for (int i = 0; i < MAX_BULLETS; i++) {
    enemyBullets[i].move();
  }
}

void checkInput() {
  if (keyPressed) {
    if (key == 'r' || key == 'R') {
      player.reload();
    } else if (key == 'q' || key == 'Q') {
      exit();
    }
  }
}

void checkMouseInput() {
  if (mousePressed) {
    if (mouseButton == LEFT) {
      player.shoot();
    } else if (mouseButton == RIGHT) {
      reset();
    }
  }
}

void checkCollisions() {
  for (int i = 0; i < MAX_BULLETS; i++) {
    Bullet bullet = playerBullets[i];
    if (bullet.isAlive()) {
      for (int j = 0; j < MAX_ENEMIES; j++) {
        Enemy enemy = enemies[j];
        if (enemy.isAlive()) {
          if (intersects(bullet.x, bullet.y, bullet.width, bullet.height, enemy.x, enemy.y, enemy.width, enemy.height)) {
            bullet.setAlive(false);
            enemy.takeDamage();
          }
        }
      }
    }
  }
  for (int i = 0; i < MAX_BULLETS; i++) {
    Bullet bullet = enemyBullets[i];
    if (bullet.isAlive()) {
      if (intersects(bullet.x, bullet.y, bullet.width, bullet.height, player.x, player.y, player.width, player.height)) {
        bullet.setAlive(false);
        player.takeDamage();
      }
    }
  }
}

boolean intersects(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  if (x1 + w1 > x2 && x1 < x2 + w2 && y1 + h1 > y2 && y1 < y2 + h2) {
    return true;
  }
  return false;
}

void drawGUI() {
  fill(255);
  textSize(24);
  text("Health: " + player.health, 10, 30);
  text("Ammo: " + player.ammo, 10, 60);
  text("Enemies: " + enemiesAlive, 10, 90);
}

void reset() {
  player = new Player();
  for (int i = 0; i < MAX_ENEMIES; i++) {
    enemies[i] = new Enemy();
  }
  for (int i = 0; i < MAX_BULLETS; i++) {
    playerBullets[i] = new Bullet(-100, -100, 0);
    enemyBullets[i] = new Bullet(-100, -100, 0);
  }
}

void gameOver() {
  fill(255);
  textSize(48);
  text("Game Over!", width / 2 - 100, height / 2);
  text("Thanks for playing, Made with chatGPT on 12/23/2022", width / 2 - 300, height / 2 + 50);
}

void keyPressed() {
  if (key == 'f') {
    fullScreen();
  }
}

void draw() {
  background(0);
  player.draw();
  drawEnemies();
  drawBullets();
  checkInput();
  checkMouseInput();
  checkCollisions();
  move();
  drawGUI();
  if (player.health <= 0) {
    gameOver();
  }
  if (enemiesAlive == 0) {
    println("You have defeated all of the enemies!");
  }
}
