use thu2rcc::calc_hash;
use criterion::{
    criterion_group,
    criterion_main,
    Criterion
};

fn hashing_speed_benchmark(c: &mut Criterion) {
    let cheat_string = "birdman".to_string();

    c.bench_function("hashing speed",
        |b| b.iter(|| calc_hash(cheat_string.clone()))
    );
}

criterion_group!(benches, hashing_speed_benchmark);
criterion_main!(benches);