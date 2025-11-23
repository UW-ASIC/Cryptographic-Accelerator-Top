import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


#Test for system level behavior
@cocotb.test()
async def test_reset(dut):
    dut._log.info("Starting system level test")

    # Set up the clock
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset the DUT
    dut._log.info("Resetting DUT")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Running system level tests")
    
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0, "Initial output should be 0 after reset"
    assert dut.uio_out.value == 0, "Initial uio output should be 0 after reset"

    dut._log.info("System level test completed successfully")
    
@cocotb.test()
async def test_reset_after_multiple_cycles(dut):
    dut._log.info("Starting reset after multiple cycles test")

    # Set up the clock
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset the DUT
    dut._log.info("Resetting DUT")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut.ui_in.value = 15
    dut.uio_in.value = 25
    await ClockCycles(dut.clk, 5)

    # Now reset again
    dut._log.info("Resetting DUT again")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 1)
    if dut.uo_out.value != 0:
        dut._log.error(f"uo_out value after reset: {dut.uo_out.value}")
    if dut.uio_out.value != 0:
        dut._log.error(f"uio_out value after reset: {dut.uio_out.value}")
    assert dut.uo_out.value == 0, "Output should be 0 after second reset"
    assert dut.uio_out.value == 0, "uio output should be 0 after second reset"

    dut._log.info("Reset after multiple cycles test completed successfully")
    
@cocotb.test()
async def test_rapid_toggle_enable(dut):
    dut._log.info("Starting rapid toggle enable test")

    # Set up the clock
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset the DUT
    dut._log.info("Resetting DUT")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Rapidly toggle enable signal
    for _ in range(5):
        dut.ena.value = 0
        await ClockCycles(dut.clk, 1)
        dut.ena.value = 1
        await ClockCycles(dut.clk, 1)

    # Set input values
    dut.ui_in.value = 10
    dut.uio_in.value = 20
    await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 30, "Output should be correct after rapid enable toggling"
    assert dut.uio_out.value == 20, "uio output should be correct after rapid enable toggling"

    dut._log.info("Rapid toggle enable test completed successfully")
    
    