"""Run the frozen K60 judge with unlimited conflicts on the Intel.

Arguments and JSONL format are the same as claudeCloud_m9_sieve_judge.py. Reuse its
answer files: decided instances are skipped and UNKNOWN instances are retried.
"""
import claudeCloud_m9_sieve_judge as judge


if __name__ == "__main__":
    judge.BUDGET = -1  # PySAT disables the conflict budget at -1.
    judge.main()
