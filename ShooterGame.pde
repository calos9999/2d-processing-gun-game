import random;
import time;
import gc;

int MAX_BULLETS = 6;
int MAX_ENEMIES = 3;

PShape playerShape;
PShape enemyShape;
PShape bossShape;
PShape gunShape;
PShape bulletShape;

class Bullet {
  int damage;
  float x;
  float y;
  float speed;
  boolean alive;

  Bullet(float x, float y, float speed) {
    damage = 10;
    this.x = x;
    this.y = y;
    this.speed = speed;
    alive = true;
  }

  int getDamage() {
    return damage;
  }

  boolean isAlive() {
    return alive;
  }

  void move() {
    x += speed;
  }
}

class Gun {
  int bullets;
  int maxBullets;

  Gun(int maxBullets) {
    this.bullets = maxBullets;
    this.maxBullets = maxBullets;
  }

  int getNumBullets() {
    return bullets;
  }

  void shoot() {
    if (bullets > 0) {
      bullets--;
    } else {
      println("You are out of bullets!");
    }
  }

  void reload() {
    println("Reloading...");
    time.sleep(1);
    bullets = maxBullets;
    println("Your gun has been reloaded!");
  }
}

class Player {
  int health;
  Gun gun;
  float x;
  float y;
  float width;
  float height;
  float speed;

  Player() {
    health = 100;
    gun = new Gun(MAX_BULLETS);
    x = 100;
    y = 100;
    width = 100;
    height = 200;
    speed = 2;
  }

  int getHealth() {
    return health;
  }

  Gun getGun() {
    return gun;
  }

  void takeDamage(int damage) {
    health -= damage;
  }

  boolean isAlive() {
    return health > 0;
  }

  boolean hasBullets() {
    return gun.getNumBullets() > 0;
  }

  boolean intersects(float x, float y, float width, float height) {
    return (x < this.x + this.width && x + width > this.x && y < this.y + this.height && y + height > this.y);
  }

    void move() {
    if (keyPressed) {
      if (key == 'w' || key == 'W') {
        y -= speed;
      } else if (key == 's' || key == 'S') {
        y += speed;
      } else if (key == 'a' || key == 'A') {
        x -= speed;
      } else if (key == 'd' || key == 'D') {
        x += speed;
      }
    }
  }
}

class Enemy {
  int health;
  Gun gun;
  float x;
  float y;
  float width;
  float height;
  float speed;
  boolean boss;

  Enemy(float x, float y, boolean boss) {
    health = 50;
    gun = new Gun(MAX_BULLETS);
    this.x = x;
    this.y = y;
    width = 100;
    height = 200;
    this.boss = boss;
    if (boss) {
      speed = 4;
      gun.maxBullets = 8;
    } else {
      speed = 2;
    }
  }

  int getHealth() {
    return health;
  }

  Gun getGun() {
    return gun;
  }

  void takeDamage(int damage) {
    health -= damage;
  }

  boolean isAlive() {
    return health > 0;
  }

  boolean hasBullets() {
    return gun.getNumBullets() > 0;
  }

  boolean isBoss() {
    return boss;
  }

  boolean intersects(float x, float y, float width, float height) {
    return (x < this.x + this.width && x + width > this.x && y < this.y + this.height && y + height > this.y);
  }

  void move() {
    x += speed;
  }
}

Player player;
Enemy[] enemies;
Bullet[] playerBullets;
Bullet[] enemyBullets;

void setup() {
  size(1920, 1080);
  playerShape = createShape(GROUP);
  enemyShape = createShape(GROUP);
  bossShape = createShape(GROUP);
  gunShape = createShape(GROUP);
  bulletShape = createShape(GROUP);
  enemies = new Enemy[MAX_ENEMIES];
  playerBullets = new Bullet[MAX_BULLETS];
  enemyBullets = new Bullet[MAX_BULLETS];
  player = new Player();
  for (int i = 0; i < MAX_ENEMIES; i++) {
    if (random(0, 1) < 0.1) {
      enemies[i] = new Enemy(random(width + 100, width + 200), random(0, height - 100), true);
    } else {
      enemies[i] = new Enemy(random(width + 100, width + 200), random(0, height - 100), false);
    }
  }
  for (int i = 0; i < MAX_BULLETS; i++) {
    playerBullets[i] = new Bullet(-100, -100, 0);
    enemyBullets[i] = new Bullet(-100, -100, 0);
  }
  createPlayerShape();
  createEnemyShape();
  createBossShape();
  createGunShape();
  createBulletShape();
}

void draw() {
  background(255);
  drawPlayer();
  drawEnemies();
  drawBullets();
  player.move();
  moveEnemies();
  checkCollisions();
  if (!player.isAlive()) {
    gameOver();
  }
  if (enemiesAlive == 0) {
    println("You have defeated all of the enemies!");
    reset();
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    player.getGun().reload();
  } else if (key == 'q' || key == 'Q') {
    exit();
  } else if (key == 'f' || key == 'F') {
    fullScreen();
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    player.getGun().shoot();
    fireBullet(player.x + player.width, player.y + player.height / 2, 10);
  } else if (mouseButton == RIGHT) {
    reset();
  }
}

int enemiesAlive() {
  int count = 0;
  for (int i = 0; i < MAX_ENEMIES; i++) {
    if (enemies[i].isAlive()) {
      count++;
    }
  }
  return count;
}

void reset() {
  player = new Player();
  for (int i = 0; i < MAX_ENEMIES; i++) {
    if (random(0, 1) < 0.1) {
      enemies[i] = new Enemy(random(width + 100, width + 200), random(0, height - 100), true);
    } else {
      enemies[i] = new Enemy(random(width + 100, width + 200), random(0, height - 100), false);
    }
  }
  for (int i = 0; i < MAX_BULLETS; i++) {
    playerBullets[i].alive = false;
    enemyBullets[i].alive = false;
  }
  gc.collect();
}

void gameOver() {
  println("Game Over!");
  reset();
}

void createPlayerShape() {
  playerShape.addChild(createShape(RECT, 0, 0, player.width, player.height));
  playerShape.addChild(createShape(ELLIPSE, player.width / 2, 0, player.width / 2, player.width / 2));
  playerShape.addChild(createShape(ELLIPSE, player.width / 2, player.height, player.width / 2, player.width / 2));
  playerShape.addChild(createShape(RECT, player.width / 2, player.height / 2 - player.width / 4, player.width / 2, player.width / 2));
  playerShape.addChild(createShape(ELLIPSE, 0, player.height / 2, player.width / 2, player.width / 2));
  playerShape.addChild(createShape(ELLIPSE, player.width, player.height / 2, player.width / 2, player.width / 2));
}

void createEnemyShape() {
  enemyShape.addChild(createShape(RECT, 0, 0, 100, 200));
  enemyShape.addChild(createShape(ELLIPSE, 50, 0, 50, 50));
  enemyShape.addChild(createShape(ELLIPSE, 50, 200, 50, 50));
  enemyShape.addChild(createShape(RECT, 50, 100 - 25, 50, 50));
  enemyShape.addChild(createShape(ELLIPSE, 0, 100, 50, 50));
  enemyShape.addChild(createShape(ELLIPSE, 100, 100, 50, 50));
}

void createBossShape() {
  bossShape.addChild(createShape(RECT, 0, 0, 100, 200));
  bossShape.addChild(createShape(ELLIPSE, 50, 0, 50, 50));
  bossShape.addChild(createShape(ELLIPSE, 50, 200, 50, 50));
  bossShape.addChild(createShape(RECT, 50, 100 - 25, 50, 50));
  bossShape.addChild(createShape(ELLIPSE, 0, 100, 50, 50));
  bossShape.addChild(createShape(ELLIPSE, 100, 100, 50, 50));
  bossShape.addChild(createShape(RECT, 25, 100 - 12.5, 50, 25));
  bossShape.addChild(createShape(RECT, 0, 75, 100, 50));
  bossShape.addChild(createShape(RECT, 0, 50, 100, 50));
  bossShape.addChild(createShape(RECT, 0, 25, 100, 50));
}

void createGunShape() {
  gunShape.addChild(createShape(RECT, 0, 0, 50, 25));
  gunShape.addChild(createShape(ELLIPSE, 25, 0, 25, 25));
  gunShape.addChild(createShape(RECT, 50, 12.5, 100, 25));
}

void createBulletShape() {
  bulletShape.addChild(createShape(ELLIPSE, 0, 0, 5, 5));
}

void drawPlayer() {
  shape(playerShape, player.x, player.y);
  drawGun(player.x, player.y, player.width, player.height);
  drawHealthBar(player.getHealth(), player.x, player.y - 20, player.width, 20, color(0, 255, 0));
}

void drawEnemies() {
  for (int i = 0; i < MAX_ENEMIES; i++) {
    Enemy enemy = enemies[i];
    if (enemy.isAlive()) {
      if (enemy.isBoss()) {
        shape(bossShape, enemy.x, enemy.y);
      } else {
        shape(enemyShape, enemy.x, enemy.y);
      }
      drawHealthBar(enemy.getHealth(), enemy.x, enemy.y - 20, enemy.width, 20, color(255, 0, 0));
      if (frameCount % enemy.getFireRate() == 0) {
        enemy.getGun().shoot();
        fireEnemyBullet(enemy.x - 50, enemy.y + enemy.height / 2, -10);
      }
    }
  }
}

void drawBullets() {
  for (int i = 0; i < MAX_BULLETS; i++) {
    Bullet bullet = playerBullets[i];
    if (bullet.isAlive()) {
      shape(bulletShape, bullet.x, bullet.y);
    }
    bullet = enemyBullets[i];
    if (bullet.isAlive()) {
      shape(bulletShape, bullet.x, bullet.y);
    }
  }
}

void drawGun(float x, float y, float width, float height) {
  pushMatrix();
  translate(x + width, y + height / 2);
  float angle = atan2(mouseY - (y + height / 2), mouseX - (x + width));
  rotate(angle);
  shape(gunShape, 0, 0);
  popMatrix();
}

void drawHealthBar(int health, float x, float y, float width, float height, color barColor) {
  fill(barColor);
  rect(x, y, map(health, 0, 100, 0, width), height);
  noFill();
}

void fireBullet(float x, float y, float speed) {
  for (int i = 0; i < MAX_BULLETS; i++) {
    Bullet bullet = playerBullets[i];
    if (!bullet.isAlive()) {
      bullet.spawn(x, y, speed);
      break;
    }
  }
}

void fireEnemyBullet(float x, float y, float speed) {
  for (int i = 0; i < MAX_BULLETS; i++) {
    Bullet bullet = enemyBullets[i];
    if (!bullet.isAlive()) {
      bullet.spawn(x, y, speed);
      break;
    }
  }
}

void moveEnemies() {
  for (int i = 0; i < MAX_ENEMIES; i++) {
    Enemy enemy = enemies[i];
    if (enemy.isAlive()) {
      enemy.move();
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
            enemy.takeDamage(player.getGun().getDamage());
            bullet.die();
            if (!enemy.isAlive()) {
              player.addScore(enemy.getPoints());
            }
            break;
          }
        }
      }
    }
    bullet = enemyBullets[i];
    if (bullet.isAlive()) {
      if (intersects(bullet.x, bullet.y, bullet.width, bullet.height, player.x, player.y, player.width, player.height)) {
        player.takeDamage(bullet.getDamage());
        bullet.die();
      }
    }
  }
}

void checkInput() {
  if (key == 'w' || key == 'W') {
    player.moveUp();
  }
  if (key == 'a' || key == 'A') {
    player.moveLeft();
  }
  if (key == 's' || key == 'S') {
    player.moveDown();
  }
  if (key == 'd' || key == 'D') {
    player.moveRight();
  }
  if (key == 'r' || key == 'R') {
    player.getGun().reload();
  }
  if (key == 'f' || key == 'F') {
    fullScreen();
  }
  if (key == 'q' || key == 'Q') {
    gameOver();
  }
}

void checkMouseInput() {
  if (mousePressed) {
    if (mouseButton == LEFT) {
      player.getGun().shoot();
      fireBullet(player.x + player.width + 10, player.y + player.height / 2, 10);
    }
    if (mouseButton == RIGHT) {
      reset();
    }
  }
}

void reset() {
  player.respawn();
  for (int i = 0; i < MAX_ENEMIES; i++) {
    enemies[i].die();
  }
  for (int i = 0; i < MAX_BULLETS; i++) {
    playerBullets[i].die();
    enemyBullets[i].die();
  }
  enemiesAlive = 0;
}

void gameOver() {
  println("Thanks for playing, Made with chatGPT on 12/23/2022");
  exit();
}

