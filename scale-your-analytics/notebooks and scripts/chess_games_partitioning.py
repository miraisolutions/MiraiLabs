import pyspark.sql.functions as sf
from pyspark import SparkConf
from pyspark.sql import SparkSession

if __name__ == "__main__":
    spark_config = (
        SparkConf()
        .setAppName("scale-your-analytics")
        .setMaster("local[*]")
        .set("spark.driver.memory", "8g")
        .set("spark.sql.adaptive.enabled", "false")  # disable AQE to see unmodified plans
    )
    spark = SparkSession.builder.config(conf=spark_config).getOrCreate()
    spark.sparkContext.setCheckpointDir("./tmp")

    # See https://www.kaggle.com/datasets/arevel/chess-games
    chess_games = (
        spark
        .read.csv("chess_games.csv", header=True)
        .withColumn("Event", sf.trim("Event"))  # contains leading and trailing whitespaces
        .repartition("Event")  # without repartition here we would get two shuffle exchanges below
        .persist()
        .checkpoint()  # just to prune the lineage
    )

    played_classical_openings = (
        chess_games
        .groupby("Event", "Opening")  # no shuffle exchange due to repartition above
        .agg(sf.count("*").alias("Count"))
        .filter(sf.col("Event") == "Classical")
    )

    played_classical_openings.explain(extended=True)
    played_classical_openings.sort("Count", ascending=False).show()

    lower_elo_wins_by_event = (
        chess_games
        .withColumn("is_lower_elo_win",
                    ((sf.col("WhiteElo") < sf.col("BlackElo")) & (sf.col("Result") == "1-0")) |
                    ((sf.col("WhiteElo") > sf.col("BlackElo")) & (sf.col("Result") == "0-1")))
        .groupby("Event")  # no shuffle exchange due to repartition above
        .agg((sf.sum(sf.col("is_lower_elo_win").cast("double")) / sf.count("*") * 100).alias("pct_lower_elo_win"))
    )

    lower_elo_wins_by_event.explain(extended=True)
    lower_elo_wins_by_event.show()
