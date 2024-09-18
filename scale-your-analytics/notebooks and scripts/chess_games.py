import pyspark.sql.functions as sf
from pyspark import SparkConf
from pyspark.sql import SparkSession

if __name__ == "__main__":
    spark_config = (
        SparkConf()
        .setAppName("scale-your-analytics")
        .setMaster("local[*]")
        .set("spark.driver.memory", "2g")
        .set("spark.sql.adaptive.enabled", "false")  # disable AQE to see unmodified plans
    )
    spark = SparkSession.builder.config(conf=spark_config).getOrCreate()

    # See https://www.kaggle.com/datasets/arevel/chess-games
    chess_games = (
        spark
        .read.csv("chess_games.csv", header=True)
        .withColumn("Event", sf.trim("Event"))  # contains leading and trailing whitespaces
    )

    played_classical_openings = (
        chess_games
        .groupby("Event", "Opening")
        .agg(sf.count("*").alias("Count"))
        .filter(sf.col("Event") == "Classical")
        .persist()
    )

    played_classical_openings.explain(extended=True)

    print(played_classical_openings.count())
    played_classical_openings.sort("Count", ascending=False).show()