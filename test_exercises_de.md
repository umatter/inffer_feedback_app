# R Code Feedback App - Manuelle Testübungen (Deutsch)

Verwenden Sie diese Übungen und Beispielantworten, um die Feedback-Qualität über verschiedene Kompetenzstufen hinweg zu testen.

---

## Übung 1: Datenimport

**Aufgabe:** Laden Sie die CSV-Datei "sales_data.csv" und zeigen Sie die ersten 6 Zeilen an.

### Antwort A: Sehr schlecht
```r
sales_data.csv
head
```

### Antwort B: Schlecht
```r
data = read.csv(sales_data.csv)
head(data)
```

### Antwort C: Gut
```r
data <- read.csv("sales_data.csv")
head(data)
```

### Antwort D: Ausgezeichnet
```r
# Verkaufsdaten aus CSV-Datei laden
sales_data <- read.csv("sales_data.csv", stringsAsFactors = FALSE)

# Erste 6 Zeilen zur Überprüfung des Imports anzeigen
head(sales_data)
```

---

## Übung 2: Deskriptive Statistik

**Aufgabe:** Berechnen Sie den Mittelwert, den Median und die Standardabweichung eines numerischen Vektors namens `preise`.

### Antwort A: Sehr schlecht
```r
mittelwert preise
median preise
sd preise
```

### Antwort B: Schlecht
```r
mean(preise)
median(preise)
sd(preise)
```

### Antwort C: Gut
```r
# Deskriptive Statistiken berechnen
mean(preise, na.rm = TRUE)
median(preise, na.rm = TRUE)
sd(preise, na.rm = TRUE)
```

### Antwort D: Ausgezeichnet
```r
# Deskriptive Statistiken für Preise berechnen
# Verwendung von na.rm = TRUE zur Behandlung fehlender Werte

preis_mittelwert <- mean(preise, na.rm = TRUE)
preis_median <- median(preise, na.rm = TRUE)
preis_sd <- sd(preise, na.rm = TRUE)

# Ergebnisse anzeigen
cat("Mittelwert:", preis_mittelwert, "\n")
cat("Median:", preis_median, "\n")
cat("Standardabweichung:", preis_sd, "\n")
```

---

## Übung 3: Datenmanipulation

**Aufgabe:** Filtern Sie aus dem `mtcars`-Datensatz die Autos mit mpg größer als 20 und wählen Sie nur die Spalten `mpg`, `cyl` und `hp` aus.

### Antwort A: Sehr schlecht
```r
mtcars mpg > 20
```

### Antwort B: Schlecht
```r
library(dplyr)
filter(mtcars, mpg > 20)
select(mpg, cyl, hp)
```

### Antwort C: Gut
```r
library(dplyr)
mtcars %>%
  filter(mpg > 20) %>%
  select(mpg, cyl, hp)
```

### Antwort D: Ausgezeichnet
```r
# dplyr für Datenmanipulation laden
library(dplyr)

# Effiziente Autos (mpg > 20) filtern und relevante Spalten auswählen
effiziente_autos <- mtcars %>%
  filter(mpg > 20) %>%
  select(mpg, cyl, hp)

# Ergebnis anzeigen
effiziente_autos
```

---

## Übung 4: Datenvisualisierung

**Aufgabe:** Erstellen Sie ein Histogramm der Variable `Sepal.Length` aus dem `iris`-Datensatz mit entsprechenden Beschriftungen.

### Antwort A: Sehr schlecht
```r
histogramm iris Sepal.Length
```

### Antwort B: Schlecht
```r
hist(iris$Sepal.Length)
```

### Antwort C: Gut
```r
hist(iris$Sepal.Length,
     main = "Verteilung der Kelchblattlänge",
     xlab = "Kelchblattlänge")
```

### Antwort D: Ausgezeichnet
```r
# Histogramm der Kelchblattlänge aus dem iris-Datensatz erstellen
hist(iris$Sepal.Length,
     main = "Verteilung der Kelchblattlänge im Iris-Datensatz",
     xlab = "Kelchblattlänge (cm)",
     ylab = "Häufigkeit",
     col = "steelblue",
     border = "white",
     breaks = 15)

# Vertikale Linie für den Mittelwert hinzufügen
abline(v = mean(iris$Sepal.Length), col = "red", lwd = 2, lty = 2)
```

---

## Übung 5: Statistische Analyse

**Aufgabe:** Führen Sie eine Korrelationsanalyse zwischen `Sepal.Length` und `Petal.Length` im iris-Datensatz durch.

### Antwort A: Sehr schlecht
```r
korrelation kelch blueten
```

### Antwort B: Schlecht
```r
cor(Sepal.Length, Petal.Length)
```

### Antwort C: Gut
```r
cor(iris$Sepal.Length, iris$Petal.Length)
```

### Antwort D: Ausgezeichnet
```r
# Pearson-Korrelation zwischen Sepal.Length und Petal.Length berechnen
korrelation <- cor(iris$Sepal.Length, iris$Petal.Length,
                   method = "pearson")

# Korrelationskoeffizienten anzeigen
cat("Korrelationskoeffizient:", round(korrelation, 3), "\n")

# Korrelationstest für Signifikanz durchführen
kor_test <- cor.test(iris$Sepal.Length, iris$Petal.Length)
print(kor_test)

# Beziehung visualisieren
plot(iris$Sepal.Length, iris$Petal.Length,
     xlab = "Kelchblattlänge (cm)",
     ylab = "Blütenblattlänge (cm)",
     main = "Kelchblatt- vs. Blütenblattlänge")
abline(lm(iris$Petal.Length ~ iris$Sepal.Length), col = "red")
```

---

## Übung 6: Datenbereinigung

**Aufgabe:** Prüfen Sie auf fehlende Werte in einem Dataframe namens `umfrage_daten` und entfernen Sie Zeilen mit NA-Werten.

### Antwort A: Sehr schlecht
```r
entferne NA umfrage_daten
```

### Antwort B: Schlecht
```r
na.omit(umfrage_daten)
```

### Antwort C: Gut
```r
# Auf fehlende Werte prüfen
sum(is.na(umfrage_daten))

# Zeilen mit NA entfernen
bereinigte_daten <- na.omit(umfrage_daten)
```

### Antwort D: Ausgezeichnet
```r
# Fehlende Werte pro Spalte prüfen
cat("Fehlende Werte pro Spalte:\n")
colSums(is.na(umfrage_daten))

# Gesamtzahl fehlender Werte
cat("\nGesamtzahl fehlender Werte:", sum(is.na(umfrage_daten)), "\n")

# Prozentsatz vollständiger Fälle anzeigen
vollstaendig_proz <- mean(complete.cases(umfrage_daten)) * 100
cat("Vollständige Fälle:", round(vollstaendig_proz, 1), "%\n")

# Zeilen mit NA-Werten entfernen
bereinigte_daten <- na.omit(umfrage_daten)

# Bereinigung überprüfen
cat("\nZeilen vorher:", nrow(umfrage_daten), "\n")
cat("Zeilen nachher:", nrow(bereinigte_daten), "\n")
```

---

## Übung 7: Streudiagramm erstellen

**Aufgabe:** Erstellen Sie ein Streudiagramm, das die Beziehung zwischen `wt` (Gewicht) und `mpg` (Meilen pro Gallone) aus dem mtcars-Datensatz zeigt.

### Antwort A: Sehr schlecht
```r
streudiagramm mtcars wt mpg
```

### Antwort B: Schlecht
```r
plot(mtcars$wt, mtcars$mpg)
```

### Antwort C: Gut
```r
plot(mtcars$wt, mtcars$mpg,
     xlab = "Gewicht",
     ylab = "MPG",
     main = "Gewicht vs. MPG")
```

### Antwort D: Ausgezeichnet
```r
# Streudiagramm: Gewicht vs. Kraftstoffeffizienz
plot(mtcars$wt, mtcars$mpg,
     xlab = "Gewicht (1000 lbs)",
     ylab = "Meilen pro Gallone",
     main = "Fahrzeuggewicht vs. Kraftstoffeffizienz",
     pch = 19,
     col = "darkblue")

# Regressionslinie zur Trenddarstellung hinzufügen
model <- lm(mpg ~ wt, data = mtcars)
abline(model, col = "red", lwd = 2)

# Legende hinzufügen
legend("topright",
       legend = c("Datenpunkte", "Trendlinie"),
       col = c("darkblue", "red"),
       pch = c(19, NA),
       lty = c(NA, 1))
```

---

## Übung 8: Arbeiten mit Faktoren

**Aufgabe:** Konvertieren Sie die Spalte `cyl` in mtcars in einen Faktor und erstellen Sie einen Boxplot von `mpg` gruppiert nach `cyl`.

### Antwort A: Sehr schlecht
```r
faktor cyl
boxplot mpg cyl
```

### Antwort B: Schlecht
```r
mtcars$cyl <- factor(mtcars$cyl)
boxplot(mpg ~ cyl)
```

### Antwort C: Gut
```r
mtcars$cyl <- factor(mtcars$cyl)
boxplot(mpg ~ cyl, data = mtcars,
        xlab = "Zylinder",
        ylab = "MPG")
```

### Antwort D: Ausgezeichnet
```r
# Zylinder in Faktor mit aussagekräftigen Labels konvertieren
mtcars$cyl_faktor <- factor(mtcars$cyl,
                            levels = c(4, 6, 8),
                            labels = c("4 Zylinder", "6 Zylinder", "8 Zylinder"))

# Boxplot zum Vergleich von MPG über Zylindergruppen erstellen
boxplot(mpg ~ cyl_faktor, data = mtcars,
        main = "Kraftstoffeffizienz nach Zylinderanzahl",
        xlab = "Motortyp",
        ylab = "Meilen pro Gallone",
        col = c("lightgreen", "lightyellow", "lightcoral"),
        border = "darkgray")

# Mittelwertpunkte hinzufügen
mittelwerte <- tapply(mtcars$mpg, mtcars$cyl_faktor, mean)
points(1:3, mittelwerte, pch = 18, col = "darkred", cex = 1.5)
```

---

## Übung 9: Schiefe berechnen

**Aufgabe:** Berechnen und interpretieren Sie die Schiefe der Variable `Sepal.Width` aus dem iris-Datensatz. Bestimmen Sie, ob die Verteilung linksschief, rechtsschief oder annähernd symmetrisch ist.

### Antwort A: Sehr schlecht
```r
schiefe iris Sepal.Width
```

### Antwort B: Schlecht
```r
library(moments)
skewness(iris$Sepal.Width)
```

### Antwort C: Gut
```r
library(moments)

# Schiefe berechnen
schiefe <- skewness(iris$Sepal.Width)
cat("Schiefe:", schiefe, "\n")

# Grundlegende Interpretation
if (schiefe > 0) {
  cat("Rechtsschiefe Verteilung\n")
} else if (schiefe < 0) {
  cat("Linksschiefe Verteilung\n")
} else {
  cat("Symmetrische Verteilung\n")
}
```

### Antwort D: Ausgezeichnet
```r
# moments-Paket für Schiefe-Berechnung laden
library(moments)

# Schiefe von Sepal.Width berechnen
schiefe_wert <- skewness(iris$Sepal.Width, na.rm = TRUE)

# Kurtosis für zusätzliche Verteilungsinformation berechnen
kurtosis_wert <- kurtosis(iris$Sepal.Width, na.rm = TRUE)

# Interpretation mit Schwellenwerten
cat("=== Verteilungsanalyse: Sepal.Width ===\n\n")
cat("Schiefe:", round(schiefe_wert, 4), "\n")
cat("Kurtosis:", round(kurtosis_wert, 4), "\n\n")

# Schiefe-Interpretation (übliche Schwellenwerte: |Schiefe| < 0.5 ist annähernd symmetrisch)
if (abs(schiefe_wert) < 0.5) {
  cat("Interpretation: Annähernd symmetrische Verteilung\n")
} else if (schiefe_wert >= 0.5) {
  cat("Interpretation: Mäßig bis stark rechtsschief (positive Schiefe)\n")
  cat("  - Ausläufer erstreckt sich zu höheren Werten\n")
  cat("  - Mittelwert > Median typischerweise\n")
} else {
  cat("Interpretation: Mäßig bis stark linksschief (negative Schiefe)\n")
  cat("  - Ausläufer erstreckt sich zu niedrigeren Werten\n")
  cat("  - Mittelwert < Median typischerweise\n")
}

# Mit Histogramm und Dichte visualisieren
par(mfrow = c(1, 2))
hist(iris$Sepal.Width, breaks = 15, probability = TRUE,
     main = "Histogramm mit Dichte", xlab = "Kelchblattbreite (cm)",
     col = "lightblue", border = "white")
lines(density(iris$Sepal.Width), col = "red", lwd = 2)
abline(v = mean(iris$Sepal.Width), col = "blue", lty = 2, lwd = 2)
abline(v = median(iris$Sepal.Width), col = "green", lty = 2, lwd = 2)
legend("topright", legend = c("Dichte", "Mittelwert", "Median"),
       col = c("red", "blue", "green"), lty = c(1, 2, 2), cex = 0.8)

# Q-Q-Plot zur Normalitätsprüfung
qqnorm(iris$Sepal.Width, main = "Q-Q-Plot")
qqline(iris$Sepal.Width, col = "red", lwd = 2)
par(mfrow = c(1, 1))
```

---

## Übung 10: Bootstrap-Konfidenzintervall für den Mittelwert

**Aufgabe:** Berechnen Sie mit dem `mtcars`-Datensatz ein 95%-Bootstrap-Konfidenzintervall für den Mittelwert von `mpg` unter Verwendung von 10.000 Bootstrap-Stichproben.

### Antwort A: Sehr schlecht
```r
bootstrap mtcars mpg 95%
konfidenzintervall mittelwert
```

### Antwort B: Schlecht
```r
boot_mittelwerte <- replicate(1000, mean(sample(mtcars$mpg)))
quantile(boot_mittelwerte, c(0.025, 0.975))
```

### Antwort C: Gut
```r
# Seed für Reproduzierbarkeit setzen
set.seed(123)

# Bootstrap-Resampling
n <- length(mtcars$mpg)
boot_mittelwerte <- replicate(10000, {
  boot_stichprobe <- sample(mtcars$mpg, n, replace = TRUE)
  mean(boot_stichprobe)
})

# 95% KI mit Perzentil-Methode berechnen
ki <- quantile(boot_mittelwerte, c(0.025, 0.975))
cat("95% Bootstrap-KI für mittleren MPG:", ki[1], "-", ki[2], "\n")
```

### Antwort D: Ausgezeichnet
```r
# Bootstrap-Konfidenzintervall für Mittelwert MPG
# Mit 10.000 Bootstrap-Replikationen

set.seed(42)  # Für Reproduzierbarkeit

# Originaldaten
mpg_daten <- mtcars$mpg
n <- length(mpg_daten)
original_mittelwert <- mean(mpg_daten)

# Anzahl der Bootstrap-Stichproben
B <- 10000

# Bootstrap-Resampling
boot_mittelwerte <- replicate(B, {
  boot_stichprobe <- sample(mpg_daten, size = n, replace = TRUE)
  mean(boot_stichprobe)
})

# Konfidenzintervalle mit verschiedenen Methoden berechnen
ki_perzentil <- quantile(boot_mittelwerte, probs = c(0.025, 0.975))

# Einfaches Bootstrap-KI (mit Bias-Korrektur)
bias <- mean(boot_mittelwerte) - original_mittelwert
ki_einfach <- c(2 * original_mittelwert - ki_perzentil[2],
                2 * original_mittelwert - ki_perzentil[1])

# Bootstrap-Standardfehler
boot_se <- sd(boot_mittelwerte)

# Normalapproximations-KI
ki_normal <- c(original_mittelwert - 1.96 * boot_se,
               original_mittelwert + 1.96 * boot_se)

# Ergebnisse ausgeben
cat("=== Bootstrap-Analyse: Mittelwert MPG ===\n\n")
cat("Stichprobengröße:", n, "\n")
cat("Bootstrap-Replikationen:", B, "\n")
cat("Ursprünglicher Stichprobenmittelwert:", round(original_mittelwert, 3), "\n")
cat("Bootstrap-SE:", round(boot_se, 3), "\n")
cat("Bootstrap-Bias:", round(bias, 4), "\n\n")

cat("95% Konfidenzintervalle:\n")
cat("  Perzentil-Methode:", round(ki_perzentil[1], 3), "-",
    round(ki_perzentil[2], 3), "\n")
cat("  Einfache Methode: ", round(ki_einfach[1], 3), "-",
    round(ki_einfach[2], 3), "\n")
cat("  Normalapprox.:    ", round(ki_normal[1], 3), "-",
    round(ki_normal[2], 3), "\n")

# Bootstrap-Verteilung visualisieren
hist(boot_mittelwerte, breaks = 50, probability = TRUE,
     main = "Bootstrap-Verteilung des Mittelwerts MPG",
     xlab = "Bootstrap-Mittelwert", col = "lightblue", border = "white")
abline(v = original_mittelwert, col = "red", lwd = 2, lty = 1)
abline(v = ki_perzentil, col = "darkgreen", lwd = 2, lty = 2)
legend("topright",
       legend = c("Urspr. Mittelwert", "95% KI"),
       col = c("red", "darkgreen"), lty = c(1, 2), lwd = 2)
```

---

## Übung 11: Bootstrap-Test für Differenz der Mittelwerte

**Aufgabe:** Führen Sie mit dem iris-Datensatz einen Bootstrap-Hypothesentest durch, um zu bestimmen, ob es einen signifikanten Unterschied im mittleren `Petal.Length` zwischen den Arten "setosa" und "versicolor" gibt. Verwenden Sie 10.000 Bootstrap-Stichproben.

### Antwort A: Sehr schlecht
```r
bootstrap test setosa versicolor blütenblatt länge
differenz mittelwerte
```

### Antwort B: Schlecht
```r
setosa <- iris$Petal.Length[iris$Species == "setosa"]
versicolor <- iris$Petal.Length[iris$Species == "versicolor"]
mean(setosa) - mean(versicolor)
```

### Antwort C: Gut
```r
# Daten für jede Art extrahieren
setosa <- iris$Petal.Length[iris$Species == "setosa"]
versicolor <- iris$Petal.Length[iris$Species == "versicolor"]

# Beobachtete Differenz
beob_diff <- mean(setosa) - mean(versicolor)

# Bootstrap unter Nullhypothese (gepoolte Daten)
set.seed(123)
gepoolt <- c(setosa, versicolor)
n1 <- length(setosa)
n2 <- length(versicolor)

boot_diffs <- replicate(10000, {
  gemischt <- sample(gepoolt)
  mean(gemischt[1:n1]) - mean(gemischt[(n1+1):(n1+n2)])
})

# p-Wert berechnen (zweiseitig)
p_wert <- mean(abs(boot_diffs) >= abs(beob_diff))
cat("Beobachtete Differenz:", beob_diff, "\n")
cat("Bootstrap p-Wert:", p_wert, "\n")
```

### Antwort D: Ausgezeichnet
```r
# Bootstrap-Hypothesentest: Differenz der mittleren Blütenblattlänge
# H0: Kein Unterschied zwischen setosa und versicolor
# H1: Es gibt einen Unterschied (zweiseitiger Test)

set.seed(2024)

# Blütenblattlängen nach Art extrahieren
setosa_blueten <- iris$Petal.Length[iris$Species == "setosa"]
versicolor_blueten <- iris$Petal.Length[iris$Species == "versicolor"]

n_setosa <- length(setosa_blueten)
n_versicolor <- length(versicolor_blueten)

# Beobachtete Teststatistik (Differenz der Mittelwerte)
beob_diff <- mean(setosa_blueten) - mean(versicolor_blueten)

# Deskriptive Statistiken
cat("=== Deskriptive Statistiken ===\n")
cat("Setosa:     n =", n_setosa, ", Mittelwert =", round(mean(setosa_blueten), 3),
    ", SD =", round(sd(setosa_blueten), 3), "\n")
cat("Versicolor: n =", n_versicolor, ", Mittelwert =", round(mean(versicolor_blueten), 3),
    ", SD =", round(sd(versicolor_blueten), 3), "\n")
cat("Beobachtete Differenz (setosa - versicolor):", round(beob_diff, 3), "\n\n")

# Bootstrap-Permutationstest unter H0
# Unter der Null sind die Artenbezeichnungen austauschbar
gepoolte_daten <- c(setosa_blueten, versicolor_blueten)
B <- 10000

boot_diffs <- replicate(B, {
  # Gepoolte Daten permutieren
  permutiert <- sample(gepoolte_daten)
  # Differenz der Mittelwerte unter Permutation berechnen
  mean(permutiert[1:n_setosa]) - mean(permutiert[(n_setosa + 1):(n_setosa + n_versicolor)])
})

# p-Wert berechnen (zweiseitig)
p_wert_zweiseitig <- mean(abs(boot_diffs) >= abs(beob_diff))

# Auch Bootstrap-KI für die Differenz berechnen (Nicht-Null-Bootstrap)
boot_diff_ki <- replicate(B, {
  boot_setosa <- sample(setosa_blueten, n_setosa, replace = TRUE)
  boot_versicolor <- sample(versicolor_blueten, n_versicolor, replace = TRUE)
  mean(boot_setosa) - mean(boot_versicolor)
})

ki_95 <- quantile(boot_diff_ki, c(0.025, 0.975))

# Ergebnisse ausgeben
cat("=== Bootstrap-Hypothesentest Ergebnisse ===\n")
cat("Anzahl Bootstrap-Stichproben:", B, "\n")
cat("Zweiseitiger p-Wert:", format(p_wert_zweiseitig, scientific = FALSE), "\n\n")

cat("=== 95% Bootstrap-KI für Differenz ===\n")
cat("KI:", round(ki_95[1], 3), "bis", round(ki_95[2], 3), "\n\n")

# Interpretation
alpha <- 0.05
cat("=== Interpretation (α =", alpha, ") ===\n")
if (p_wert_zweiseitig < alpha) {
  cat("H0 ablehnen: Signifikanter Unterschied in der mittleren Blütenblattlänge\n")
  cat("zwischen setosa und versicolor Arten.\n")
} else {
  cat("H0 nicht ablehnen: Kein signifikanter Unterschied festgestellt.\n")
}

# Effektstärke (Cohen's d)
gepoolte_sd <- sqrt(((n_setosa - 1) * var(setosa_blueten) +
                      (n_versicolor - 1) * var(versicolor_blueten)) /
                     (n_setosa + n_versicolor - 2))
cohens_d <- beob_diff / gepoolte_sd
cat("Cohen's d:", round(cohens_d, 3), "(Effektstärke)\n")

# Visualisierung
par(mfrow = c(1, 2))

# Permutationsverteilung
hist(boot_diffs, breaks = 50, probability = TRUE,
     main = "Permutationsverteilung\n(unter H0)",
     xlab = "Differenz der Mittelwerte", col = "lightgray", border = "white")
abline(v = beob_diff, col = "red", lwd = 3)
abline(v = -beob_diff, col = "red", lwd = 3, lty = 2)
legend("topright", legend = c("Beob. Diff.", "Gespiegelt"),
       col = "red", lty = c(1, 2), lwd = 2, cex = 0.8)

# Bootstrap-KI-Verteilung
hist(boot_diff_ki, breaks = 50, probability = TRUE,
     main = "Bootstrap-Verteilung\nder Differenz",
     xlab = "Differenz der Mittelwerte", col = "lightblue", border = "white")
abline(v = ki_95, col = "darkgreen", lwd = 2, lty = 2)
abline(v = beob_diff, col = "red", lwd = 2)
legend("topright", legend = c("Beobachtet", "95% KI"),
       col = c("red", "darkgreen"), lty = c(1, 2), lwd = 2, cex = 0.8)

par(mfrow = c(1, 1))
```

---

## Übung 12: Konfidenzintervall für Anteilswert

**Aufgabe:** In einer Umfrage unter 500 Kunden gaben 320 an, das Produkt weiterzuempfehlen. Berechnen Sie ein 95%-Konfidenzintervall für den wahren Anteil der Kunden, die das Produkt weiterempfehlen würden, sowohl mit der Normalapproximation als auch mit der exakten (Clopper-Pearson) Methode.

### Antwort A: Sehr schlecht
```r
konfidenzintervall 320/500 anteil
95% KI empfehlung
```

### Antwort B: Schlecht
```r
prop.test(320, 500)
```

### Antwort C: Gut
```r
# Stichprobendaten
erfolge <- 320
n <- 500
p_dach <- erfolge / n

# Normalapproximations-KI
se <- sqrt(p_dach * (1 - p_dach) / n)
ki_normal <- c(p_dach - 1.96 * se, p_dach + 1.96 * se)

cat("Stichprobenanteil:", p_dach, "\n")
cat("95% KI (normal):", ki_normal[1], "-", ki_normal[2], "\n")

# Mit prop.test zum Vergleich
prop.test(erfolge, n, conf.level = 0.95)
```

### Antwort D: Ausgezeichnet
```r
# Konfidenzintervall für Anteilswert
# Umfrage: 320 von 500 Kunden empfehlen das Produkt weiter

erfolge <- 320
n <- 500
p_dach <- erfolge / n
q_dach <- 1 - p_dach

cat("=== Stichprobenstatistiken ===\n")
cat("Stichprobengröße (n):", n, "\n")
cat("Erfolge (x):", erfolge, "\n")
cat("Stichprobenanteil (p̂):", round(p_dach, 4), "\n\n")

# Prüfen ob Normalapproximation angemessen ist
# Faustregel: np >= 10 und n(1-p) >= 10
cat("=== Gültigkeitsprüfung für Normalapproximation ===\n")
cat("n * p̂ =", n * p_dach, "(sollte >= 10 sein)\n")
cat("n * (1-p̂) =", n * q_dach, "(sollte >= 10 sein)\n")
cat("Normalapproximation:", ifelse(n * p_dach >= 10 & n * q_dach >= 10,
                                   "GÜLTIG", "EXAKTE METHODE VERWENDEN"), "\n\n")

# Methode 1: Wald (Normalapproximations) Intervall
se_wald <- sqrt(p_dach * q_dach / n)
z_krit <- qnorm(0.975)
ki_wald <- c(p_dach - z_krit * se_wald, p_dach + z_krit * se_wald)

# Methode 2: Wilson-Score-Intervall (bessere Überdeckungseigenschaften)
wilson_ergebnis <- prop.test(erfolge, n, conf.level = 0.95, correct = FALSE)
ki_wilson <- wilson_ergebnis$conf.int

# Methode 3: Clopper-Pearson exaktes Intervall
ki_exakt <- binom.test(erfolge, n, conf.level = 0.95)$conf.int

# Methode 4: Agresti-Coull Intervall
n_tilde <- n + z_krit^2
p_tilde <- (erfolge + z_krit^2 / 2) / n_tilde
se_ac <- sqrt(p_tilde * (1 - p_tilde) / n_tilde)
ki_agresti <- c(p_tilde - z_krit * se_ac, p_tilde + z_krit * se_ac)

# Alle Intervalle ausgeben
cat("=== 95% Konfidenzintervalle ===\n\n")
cat("Methode             Untere   Obere    Breite\n")
cat("-----------------------------------------------\n")
cat(sprintf("Wald (Normal):      %.4f   %.4f   %.4f\n",
            ki_wald[1], ki_wald[2], diff(ki_wald)))
cat(sprintf("Wilson-Score:       %.4f   %.4f   %.4f\n",
            ki_wilson[1], ki_wilson[2], diff(ki_wilson)))
cat(sprintf("Clopper-Pearson:    %.4f   %.4f   %.4f\n",
            ki_exakt[1], ki_exakt[2], diff(ki_exakt)))
cat(sprintf("Agresti-Coull:      %.4f   %.4f   %.4f\n",
            ki_agresti[1], ki_agresti[2], diff(ki_agresti)))

cat("\n=== Interpretation ===\n")
cat("Mit 95% Konfidenz liegt der wahre Anteil der Kunden,\n")
cat("die das Produkt weiterempfehlen würden, zwischen",
    round(ki_wilson[1] * 100, 1), "% und",
    round(ki_wilson[2] * 100, 1), "%.\n")

# Visualisierung
anteile <- c(p_dach, p_dach, p_dach, p_dach)
untere <- c(ki_wald[1], ki_wilson[1], ki_exakt[1], ki_agresti[1])
obere <- c(ki_wald[2], ki_wilson[2], ki_exakt[2], ki_agresti[2])
methoden <- c("Wald", "Wilson", "Clopper-Pearson", "Agresti-Coull")

# Konfidenzintervalle plotten
par(mar = c(5, 12, 4, 2))
plot(NULL, xlim = c(0.58, 0.70), ylim = c(0.5, 4.5),
     xlab = "Anteil", ylab = "", yaxt = "n",
     main = "95% Konfidenzintervalle für Anteilswert")
axis(2, at = 1:4, labels = methoden, las = 1)
abline(v = p_dach, col = "red", lty = 2, lwd = 2)

for (i in 1:4) {
  segments(untere[i], i, obere[i], i, lwd = 3, col = "darkblue")
  points(c(untere[i], obere[i]), c(i, i), pch = "|", cex = 1.5, col = "darkblue")
  points(anteile[i], i, pch = 19, col = "red", cex = 1.2)
}
legend("topright", legend = c("Punktschätzer", "95% KI"),
       col = c("red", "darkblue"), pch = c(19, NA), lty = c(NA, 1), lwd = 2)
par(mar = c(5, 4, 4, 2))
```

---

## Übung 13: Normalitätsprüfung mit Schiefe und Kurtosis

**Aufgabe:** Generieren Sie eine Stichprobe von 200 Beobachtungen aus einer Exponentialverteilung mit Rate = 0,5. Berechnen Sie die Schiefe und Kurtosis und beurteilen Sie, wie die Verteilung von der Normalverteilung abweicht.

### Antwort A: Sehr schlecht
```r
exponential stichprobe 200 rate 0.5
schiefe kurtosis normalität
```

### Antwort B: Schlecht
```r
set.seed(1)
x <- rexp(200, rate = 0.5)
library(moments)
skewness(x)
kurtosis(x)
```

### Antwort C: Gut
```r
library(moments)

# Exponential-Stichprobe generieren
set.seed(42)
exp_stichprobe <- rexp(200, rate = 0.5)

# Momente berechnen
schiefe <- skewness(exp_stichprobe)
kurt <- kurtosis(exp_stichprobe)

cat("Schiefe:", round(schiefe, 3), "\n")
cat("Kurtosis:", round(kurt, 3), "\n")

# Referenz: Normalverteilung hat Schiefe=0, Kurtosis=3
cat("\nAbweichung von Normal:\n")
cat("Schiefe-Abweichung:", round(schiefe - 0, 3), "\n")
cat("Exzess-Kurtosis:", round(kurt - 3, 3), "\n")

# Visuelle Prüfung
hist(exp_stichprobe, breaks = 20, probability = TRUE, main = "Exponential-Stichprobe")
curve(dexp(x, rate = 0.5), add = TRUE, col = "red", lwd = 2)
```

### Antwort D: Ausgezeichnet
```r
# Normalitätsprüfung mit Schiefe und Kurtosis
# Stichprobe: 200 Beobachtungen aus Exponential(rate = 0.5)

library(moments)

set.seed(2024)

# Stichprobe generieren
n <- 200
rate <- 0.5
exp_stichprobe <- rexp(n, rate = rate)

# Theoretische Werte für Exp(rate) Verteilung
# Erwartungswert = 1/rate, Varianz = 1/rate^2
# Schiefe = 2 (immer bei Exponential)
# Kurtosis = 9 (Exzess-Kurtosis = 6)
theo_mittel <- 1 / rate
theo_var <- 1 / rate^2
theo_schiefe <- 2
theo_kurt <- 9  # (Exzess = 6)

# Stichprobenstatistiken
stichp_mittel <- mean(exp_stichprobe)
stichp_var <- var(exp_stichprobe)
stichp_schiefe <- skewness(exp_stichprobe)
stichp_kurt <- kurtosis(exp_stichprobe)  # moments-Paket gibt reguläre Kurtosis zurück

# Standardfehler für Schiefe und Kurtosis (unter Normalitätsannahme)
se_schiefe <- sqrt(6 / n)
se_kurt <- sqrt(24 / n)

# Z-Tests für Normalität
z_schiefe <- stichp_schiefe / se_schiefe
z_kurt <- (stichp_kurt - 3) / se_kurt  # Test gegen normale Kurtosis = 3

# Jarque-Bera-Test für Normalität
jb_test <- jarque.test(exp_stichprobe)

cat("=== Stichprobengenerierung ===\n")
cat("Verteilung: Exponential(rate =", rate, ")\n")
cat("Stichprobengröße:", n, "\n\n")

cat("=== Deskriptive Statistiken ===\n")
cat(sprintf("%-20s %10s %10s\n", "Statistik", "Stichprobe", "Theoretisch"))
cat(sprintf("%-20s %10.3f %10.3f\n", "Mittelwert", stichp_mittel, theo_mittel))
cat(sprintf("%-20s %10.3f %10.3f\n", "Varianz", stichp_var, theo_var))
cat(sprintf("%-20s %10.3f %10.3f\n", "Schiefe", stichp_schiefe, theo_schiefe))
cat(sprintf("%-20s %10.3f %10.3f\n", "Kurtosis", stichp_kurt, theo_kurt))

cat("\n=== Normalitätsprüfung ===\n")
cat("Referenz: Normalverteilung hat Schiefe = 0, Kurtosis = 3\n\n")

cat("Schiefe-Test:\n")
cat("  Stichproben-Schiefe:", round(stichp_schiefe, 3), "\n")
cat("  SE (unter H0):", round(se_schiefe, 3), "\n")
cat("  Z-Statistik:", round(z_schiefe, 3), "\n")
cat("  Schlussfolgerung:", ifelse(abs(z_schiefe) > 1.96,
                                  "Normalität ABLEHNEN (p < 0.05)",
                                  "Normalität nicht ablehnen"), "\n\n")

cat("Kurtosis-Test:\n")
cat("  Stichproben-Kurtosis:", round(stichp_kurt, 3), "\n")
cat("  Exzess-Kurtosis:", round(stichp_kurt - 3, 3), "\n")
cat("  SE (unter H0):", round(se_kurt, 3), "\n")
cat("  Z-Statistik:", round(z_kurt, 3), "\n")
cat("  Schlussfolgerung:", ifelse(abs(z_kurt) > 1.96,
                                  "Normalität ABLEHNEN (p < 0.05)",
                                  "Normalität nicht ablehnen"), "\n\n")

cat("Jarque-Bera-Test:\n")
cat("  Teststatistik:", round(jb_test$statistic, 3), "\n")
cat("  p-Wert:", format(jb_test$p.value, digits = 4), "\n")
cat("  Schlussfolgerung:", ifelse(jb_test$p.value < 0.05,
                                  "Normalität ABLEHNEN",
                                  "Normalität nicht ablehnen"), "\n")

cat("\n=== Interpretation ===\n")
cat("Die Exponentialverteilung ist:\n")
cat("  - Rechtsschief (positive Schiefe = 2)\n")
cat("  - Leptokurtisch (schwere Ränder, Kurtosis > 3)\n")
cat("Diese Eigenschaften machen sie deutlich nicht-normal.\n")

# Umfassende Visualisierung
par(mfrow = c(2, 2))

# 1. Histogramm mit theoretischen Dichten
hist(exp_stichprobe, breaks = 25, probability = TRUE,
     main = "Histogramm mit Dichtekurven",
     xlab = "Wert", col = "lightblue", border = "white")
curve(dexp(x, rate = rate), add = TRUE, col = "red", lwd = 2)
curve(dnorm(x, mean = stichp_mittel, sd = sqrt(stichp_var)),
      add = TRUE, col = "blue", lwd = 2, lty = 2)
legend("topright", legend = c("Exponential", "Normal-Anpassung"),
       col = c("red", "blue"), lty = c(1, 2), lwd = 2, cex = 0.8)

# 2. Q-Q-Plot gegen Normal
qqnorm(exp_stichprobe, main = "Q-Q-Plot (vs. Normal)", pch = 20, col = "darkblue")
qqline(exp_stichprobe, col = "red", lwd = 2)

# 3. Q-Q-Plot gegen Exponential
exp_theoretisch <- qexp(ppoints(n), rate = rate)
plot(sort(exp_theoretisch), sort(exp_stichprobe),
     main = "Q-Q-Plot (vs. Exponential)",
     xlab = "Theoretische Quantile", ylab = "Stichproben-Quantile",
     pch = 20, col = "darkgreen")
abline(0, 1, col = "red", lwd = 2)

# 4. Boxplot mit Referenz
boxplot(exp_stichprobe, horizontal = TRUE,
        main = "Boxplot der Stichprobe",
        xlab = "Wert", col = "lightyellow")
points(stichp_mittel, 1, pch = 18, col = "red", cex = 2)
legend("topright", legend = "Mittelwert", pch = 18, col = "red", cex = 0.8)

par(mfrow = c(1, 1))
```

---

## Testhinweise

Beim Testen mit diesen Antworten überprüfen Sie, ob die App:

1. **Sehr schlechte Antworten**: Syntaxfehler identifiziert und grundlegende Hinweise gibt
2. **Schlechte Antworten**: Fehlende Elemente aufzeigt (Anführungszeichen, korrekte Funktionsaufrufe, etc.)
3. **Gute Antworten**: Korrektheit bestätigt und Verbesserungen vorschlägt
4. **Ausgezeichnete Antworten**: Best Practices lobt (Kommentare, aussagekräftige Variablennamen, Visualisierungsverbesserungen)

### Erwartete Feedback-Elemente

| Antwortstufe | Erwartetes Feedback |
|--------------|---------------------|
| Sehr schlecht | Syntaxfehler, grundlegende R-Syntax-Anleitung |
| Schlecht | Fehlende Anführungszeichen, unvollständiger Code, grundlegende Korrekturen |
| Gut | Funktioniert korrekt, Verbesserungen vorschlagen (Kommentare, na.rm, Beschriftungen) |
| Ausgezeichnet | Lob für Best Practices, evtl. kleine Stilvorschläge |

### Hinweise zu fortgeschrittenen Übungen (9-13)

Die fortgeschrittenen Übungen behandeln statistische Inferenzthemen, die tieferes Verständnis erfordern:

| Übung | Thema | Wichtige Konzepte zur Prüfung |
|-------|-------|------------------------------|
| 9 | Schiefe | Interpretationsschwellenwerte, Bibliotheksnutzung (`moments`), Visualisierung |
| 10 | Bootstrap-KI | Resampling mit Zurücklegen, Perzentil-Methode, `set.seed()` |
| 11 | Bootstrap-Differenz | Permutationstest, gepoolte Daten, p-Wert-Berechnung, Effektstärke |
| 12 | Anteils-KI | Gültigkeit der Normalapproximation, mehrere Methoden (Wald, Wilson, exakt) |
| 13 | Normalitätsprüfung | Jarque-Bera-Test, Q-Q-Plots, Interpretation von Schiefe/Kurtosis |

**Bei fortgeschrittenen Übungen sollte die KI:**
- Erkennen wenn `library(moments)` benötigt aber nicht vorhanden ist
- Auf Reproduzierbarkeit prüfen (`set.seed()`)
- Bootstrap-Stichprobengröße validieren (sollte groß sein, z.B. 10000)
- Statistische Interpretation kommentieren, nicht nur Code-Mechanik
- Visualisierungen vorschlagen wenn angemessen
